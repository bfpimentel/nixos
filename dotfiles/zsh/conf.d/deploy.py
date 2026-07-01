#!/usr/bin/env python3

from __future__ import annotations

import getpass
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import TextIO

import pexpect


VALID_TARGETS = ("powers", "thronos")
SUDO_PROMPT = re.compile(r"(?i)\[sudo\] password for [^:\r\n]+:")
PALETTE = {
    "teal": "#89b482",
    "blue": "#7daea3",
    "green": "#a9b665",
    "red": "#ea6962",
    "yellow": "#d8a657",
    "muted": "#928374",
}


class Deployment:
    def __init__(self, repo: Path, targets: list[str]) -> None:
        self.repo = repo
        self.targets = targets
        self.states = dict.fromkeys(targets, "pending")
        self.host = ""
        self.current_step = ""
        self.current_state = ""
        self.password: str | None = None
        self.color = sys.stdout.isatty() and "NO_COLOR" not in os.environ

    def paint(self, text: str, color: str, *, bold: bool = False) -> str:
        if not self.color:
            return text
        red, green, blue = bytes.fromhex(PALETTE[color][1:])
        weight = "1;" if bold else ""
        return f"\033[{weight}38;2;{red};{green};{blue}m{text}\033[0m"

    def box_line(
        self, text: str, width: int, *, color: str = "muted", bold: bool = False
    ) -> str:
        available = width - 6
        if len(text) > available:
            text = f"{text[: available - 1]}…"
        body = f"  {text.ljust(available)}  "
        border = self.paint("│", "muted")
        return f"{border}{self.paint(body, color, bold=bold)}{border}"

    def divider(self, label: str, width: int) -> str:
        prefix = f"├─ {label} "
        return self.paint(prefix + "─" * (width - len(prefix) - 1) + "┤", "muted")

    def render(self) -> None:
        if sys.stdout.isatty():
            print("\033[2J\033[H", end="")

        columns = shutil.get_terminal_size((80, 24)).columns
        title = " NIXOS // FLEET DEPLOY "
        width = max(len(title) + 3, min(columns - 2, 78))
        top = f"╭─{title}{'─' * (width - len(title) - 3)}╮"
        print(self.paint(top, "teal", bold=True))
        print(self.box_line(str(self.repo), width, color="blue"))
        print(self.divider("HOSTS", width))

        markers = {
            "pending": ("○", "queued", "muted"),
            "running": ("◆", "deploying", "yellow"),
            "done": ("●", "complete", "green"),
            "failed": ("×", "failed", "red"),
        }
        for target in self.targets:
            marker, label, color = markers[self.states[target]]
            print(
                self.box_line(
                    f"{marker}  {target.ljust(16)} {label.upper()}",
                    width,
                    color=color,
                    bold=self.states[target] == "running",
                )
            )

        if self.current_step:
            print(self.divider("ACTIVE", width))
            stages = ("CONNECT", "SYNC", "SWITCH", "DONE")
            stage_index = {
                "prepare remote": 0,
                "rsync dotfiles": 1,
                "nixos-rebuild switch": 2,
                "complete": 3,
                "all deployments completed": 3,
            }.get(self.current_step, 0)
            track = " ── ".join(
                f"{'●' if index < stage_index else '◆' if index == stage_index else '○'} {stage}"
                for index, stage in enumerate(stages)
            )
            active_color = (
                "red"
                if self.current_state == "failed"
                else "green"
                if self.current_state in {"done", "ok"}
                else "yellow"
            )
            print(self.box_line(track, width, color=active_color))
            detail = (
                "fleet :: all deployments completed"
                if self.current_step == "all deployments completed"
                else f"{self.host} :: {self.current_step} [{self.current_state}]"
            )
            print(self.box_line(detail, width, color=active_color, bold=True))

        complete = sum(state == "done" for state in self.states.values())
        footer = f"{complete}/{len(self.targets)} hosts complete"
        bottom = f"╰─ {footer} {'─' * (width - len(footer) - 5)}╯"
        print(self.paint(bottom, "teal"))

    def step(self, label: str, state: str) -> None:
        self.current_step = label
        self.current_state = state
        self.render()

    def report_failure(self, label: str, log: TextIO) -> None:
        self.states[self.host] = "failed"
        self.step(label, "failed")
        log.seek(0)
        print(f"\n---- {self.host} :: {label} log ----", file=sys.stderr)
        print(log.read(), end="", file=sys.stderr)
        print("---- end log ----", file=sys.stderr)

    def write_rebuild_log(self, log: TextIO, output: str) -> None:
        if self.password:
            output = output.replace(self.password, "[redacted]")
        log.write(output)

    def run_quiet(self, label: str, command: list[str]) -> bool:
        self.step(label, "running")
        with tempfile.TemporaryFile(mode="w+t", encoding="utf-8") as log:
            result = subprocess.run(
                command,
                stdout=log,
                stderr=subprocess.STDOUT,
                text=True,
                check=False,
            )
            if result.returncode != 0:
                self.report_failure(label, log)
                return False

        self.step(label, "ok")
        return True

    def run_rebuild(self) -> bool:
        label = "nixos-rebuild switch"
        command = [
            "nix",
            "run",
            "nixpkgs#nixos-rebuild",
            "--",
            "switch",
            "--flake",
            f"{self.repo}#{self.host}",
            "--target-host",
            self.host,
            "--build-host",
            self.host,
            "--sudo",
            "--ask-sudo-password",
        ]

        if self.password is None:
            self.password = getpass.getpass("sudo password for remote hosts: ")
            self.render()

        with tempfile.TemporaryFile(mode="w+t", encoding="utf-8") as log:
            child = pexpect.spawn(
                command[0],
                command[1:],
                encoding="utf-8",
                codec_errors="replace",
                timeout=None,
            )

            try:
                while True:
                    match = child.expect([SUDO_PROMPT, pexpect.EOF])
                    self.write_rebuild_log(log, child.before)
                    if match == 1:
                        break
                    child.sendline(self.password)
            finally:
                child.close(force=child.isalive())

            returncode = child.exitstatus
            if returncode is None:
                returncode = 128 + (child.signalstatus or 0)

            if returncode != 0:
                self.report_failure(label, log)
                return False

        self.step(label, "ok")
        return True

    def run(self) -> int:
        self.render()

        try:
            for host in self.targets:
                self.host = host
                self.states[host] = "running"

                if not self.run_quiet(
                    "prepare remote", ["ssh", host, "mkdir -p ~/.dotfiles"]
                ):
                    return 1

                if not self.run_quiet(
                    "rsync dotfiles",
                    [
                        "rsync",
                        "-az",
                        "--delete",
                        "--filter=:- .gitignore",
                        "--exclude=.git/",
                        f"{self.repo}/",
                        f"{host}:~/.dotfiles/",
                    ],
                ):
                    return 1

                self.step("nixos-rebuild switch", "running")
                if not self.run_rebuild():
                    return 1

                self.states[host] = "done"
                self.step("complete", "done")
        finally:
            self.password = None

        self.current_step = "all deployments completed"
        self.current_state = "done"
        self.render()
        return 0


def main() -> int:
    targets = sys.argv[1:] or list(VALID_TARGETS)
    unknown = [target for target in targets if target not in VALID_TARGETS]
    if unknown:
        print(f"unknown deploy target: {unknown[0]}", file=sys.stderr)
        print(f"valid targets: {' '.join(VALID_TARGETS)}", file=sys.stderr)
        return 1

    repo = Path(os.environ.get("DOTFILES", Path.home() / ".dotfiles")).expanduser()
    return Deployment(repo, targets).run()


if __name__ == "__main__":
    raise SystemExit(main())
