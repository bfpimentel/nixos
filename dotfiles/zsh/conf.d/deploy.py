#!/usr/bin/env python3

from __future__ import annotations

import argparse
import getpass
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Callable, TextIO

import pexpect
from rich.text import Text
from textual.app import App, ComposeResult
from textual.events import Key
from textual.widgets import RichLog, Static


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
    def __init__(
        self,
        repo: Path,
        targets: list[str],
        *,
        remote_build: bool = False,
        render_callback: Callable[[str], None] | None = None,
        log_callback: Callable[[str], None] | None = None,
    ) -> None:
        self.repo = repo
        self.targets = targets
        self.remote_build = remote_build
        self.states = dict.fromkeys(targets, "pending")
        self.host = ""
        self.current_step = ""
        self.current_state = ""
        self.password: str | None = None
        self.color = sys.stdout.isatty() and "NO_COLOR" not in os.environ
        self.render_callback = render_callback
        self.log_callback = log_callback

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
        columns = shutil.get_terminal_size((80, 24)).columns
        title = " NIXOS // FLEET DEPLOY "
        width = max(len(title) + 3, min(columns - 2, 78))
        top = f"╭─{title}{'─' * (width - len(title) - 3)}╮"
        lines = [
            self.paint(top, "teal", bold=True),
            self.box_line(str(self.repo), width, color="blue"),
            self.box_line(
                "build :: remote host"
                if self.remote_build
                else "build :: local native Linux builder",
                width,
                color="blue",
            ),
            self.divider("HOSTS", width),
        ]

        markers = {
            "pending": ("○", "queued", "muted"),
            "running": ("◆", "deploying", "yellow"),
            "done": ("●", "complete", "green"),
            "failed": ("×", "failed", "red"),
        }
        for target in self.targets:
            marker, label, color = markers[self.states[target]]
            lines.append(
                self.box_line(
                    f"{marker}  {target.ljust(16)} {label.upper()}",
                    width,
                    color=color,
                    bold=self.states[target] == "running",
                )
            )

        if self.current_step:
            lines.append(self.divider("ACTIVE", width))
            if self.remote_build:
                stages = ("CONNECT", "SYNC", "SWITCH", "DONE")
                stage_index = {
                    "prepare remote": 0,
                    "rsync dotfiles": 1,
                    "nixos-rebuild switch": 2,
                    "complete": 3,
                    "all deployments completed": 3,
                }.get(self.current_step, 0)
            else:
                stages = ("BUILD + SWITCH", "DONE")
                stage_index = {
                    "nixos-rebuild switch": 0,
                    "complete": 1,
                    "all deployments completed": 1,
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
            lines.append(self.box_line(track, width, color=active_color))
            detail = (
                "fleet :: all deployments completed"
                if self.current_step == "all deployments completed"
                else f"{self.host} :: {self.current_step} [{self.current_state}]"
            )
            lines.append(self.box_line(detail, width, color=active_color, bold=True))

        complete = sum(state == "done" for state in self.states.values())
        footer = f"{complete}/{len(self.targets)} hosts complete"
        bottom = f"╰─ {footer} {'─' * (width - len(footer) - 5)}╯"
        lines.append(self.paint(bottom, "teal"))
        output = "\n".join(lines)
        if self.render_callback:
            self.render_callback(output)
        else:
            if sys.stdout.isatty():
                print("\033[2J\033[H", end="")
            print(output)

    def step(self, label: str, state: str) -> None:
        self.current_step = label
        self.current_state = state
        self.render()

    def report_failure(self, label: str, log: TextIO) -> None:
        self.states[self.host] = "failed"
        self.step(label, "failed")
        if self.log_callback:
            self.log_callback(f"\n---- {self.host} :: {label} failed ----\n")
        else:
            log.seek(0)
            print(f"\n---- {self.host} :: {label} log ----", file=sys.stderr)
            print(log.read(), end="", file=sys.stderr)
            print("---- end log ----", file=sys.stderr)

    def write_rebuild_log(self, log: TextIO, output: str) -> None:
        if self.password:
            output = output.replace(self.password, "[redacted]")
        log.write(output)
        log.flush()
        if self.log_callback:
            self.log_callback(output)

    def run_quiet(self, label: str, command: list[str]) -> bool:
        self.step(label, "running")
        with tempfile.TemporaryFile(mode="w+t", encoding="utf-8") as log:
            result = subprocess.Popen(
                command,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                bufsize=1,
            )
            assert result.stdout is not None
            for output in result.stdout:
                self.write_rebuild_log(log, output)
            returncode = result.wait()
            if returncode != 0:
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
            "--no-reexec",
            "--flake",
            f"{self.repo}#{self.host}",
            "--target-host",
            self.host,
        ]

        if self.remote_build:
            command.extend(["--build-host", self.host])

        command.extend(["--sudo", "--ask-sudo-password"])

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
            child.logfile_read = RebuildLog(self, log)

            try:
                while True:
                    match = child.expect([SUDO_PROMPT, pexpect.EOF])
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

                if self.remote_build:
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
                            "--exclude=.cache/",
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


class RebuildLog:
    def __init__(self, deployment: Deployment, log: TextIO) -> None:
        self.deployment = deployment
        self.log = log

    def write(self, output: str) -> None:
        self.deployment.write_rebuild_log(self.log, output)

    def flush(self) -> None:
        self.log.flush()


class DeploymentApp(App[int]):
    CSS = """
    Screen {
        layout: vertical;
        background: transparent;
    }

    #dashboard {
        height: auto;
        padding: 0 1;
    }

    #logs {
        height: 1fr;
        margin: 1 1 0 1;
        border: round #928374;
        background: transparent;
        color: #d4be98;
        scrollbar-color: #7daea3;
        scrollbar-color-hover: #89b482;
        scrollbar-color-active: #a9b665;
    }
    """

    def __init__(
        self, repo: Path, targets: list[str], password: str, *, remote_build: bool
    ) -> None:
        super().__init__()
        self.deployment_result = 0
        self.deployment_finished = False
        self.log_buffer = ""
        self.deployment = Deployment(
            repo,
            targets,
            remote_build=remote_build,
            render_callback=self.render_dashboard,
            log_callback=self.write_log,
        )
        self.deployment.password = password

    def compose(self) -> ComposeResult:
        yield Static(id="dashboard")
        yield RichLog(id="logs", wrap=True, highlight=False, markup=False)

    def on_mount(self) -> None:
        logs = self.query_one("#logs", RichLog)
        logs.border_title = "LIVE LOG"
        logs.focus()
        self.run_worker(self.deploy, thread=True)

    def render_dashboard(self, output: str) -> None:
        self.call_from_thread(
            self.query_one("#dashboard", Static).update, Text.from_ansi(output)
        )

    def write_log(self, output: str) -> None:
        self.call_from_thread(self.append_log, output)

    def append_log(self, output: str, *, flush: bool = False) -> None:
        self.log_buffer += output.replace("\r\n", "\n").replace("\r", "\n")
        lines = self.log_buffer.split("\n")
        self.log_buffer = "" if flush else lines.pop()
        if flush and self.log_buffer:
            lines.append(self.log_buffer)
            self.log_buffer = ""

        logs = self.query_one("#logs", RichLog)
        for line in lines:
            rendered = Text.from_ansi(line)
            if rendered.plain.strip():
                logs.write(rendered)

    def deploy(self) -> None:
        self.call_from_thread(self.finish_deployment, self.deployment.run())

    def finish_deployment(self, result: int) -> None:
        self.deployment_result = result
        self.deployment_finished = True
        self.append_log("", flush=True)
        logs = self.query_one("#logs", RichLog)
        logs.border_title = "DEPLOYMENT FINISHED"
        logs.write(Text("Press any key to exit", style="bold #d8a657"))

    def on_key(self, event: Key) -> None:
        if self.deployment_finished:
            event.stop()
            self.exit(self.deployment_result)


def main() -> int:
    parser = argparse.ArgumentParser(description="Deploy the NixOS fleet")
    parser.add_argument(
        "--remote-build",
        action="store_true",
        help="build on each target host instead of using the local Linux builder",
    )
    parser.add_argument("targets", nargs="*", choices=VALID_TARGETS)
    args = parser.parse_args()
    targets = args.targets or list(VALID_TARGETS)

    repo = Path(os.environ.get("DOTFILES", Path.home() / ".dotfiles")).expanduser()
    if sys.stdin.isatty() and sys.stdout.isatty():
        password = getpass.getpass("sudo password for remote hosts: ")
        result = DeploymentApp(
            repo, targets, password, remote_build=args.remote_build
        ).run()
        return result or 0
    return Deployment(repo, targets, remote_build=args.remote_build).run()


if __name__ == "__main__":
    raise SystemExit(main())
