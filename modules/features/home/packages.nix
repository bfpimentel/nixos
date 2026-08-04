{ inputs, ... }:

{
  config.bfmp.hm.sharedModules = [
    (
      { pkgs, util, ... }:
      {
        home.packages = with pkgs; [
          bun
          nodejs_22

          antidote
          oh-my-posh

          curl
          git
          lazygit
          wget
          uv

          fastfetch
          fzf
          gnupg
          libpcap
          ripgrep

          lua
        ];
      }
    )
  ];

  config.bfmp.hm.hosts.seraphim.modules = [
    (
      { pkgs, ... }:
      let
        androidComposition = pkgs.androidenv.composeAndroidPackages {
          platformVersions = [
            "latest"
            "36"
            "35"
          ];
          buildToolsVersions = [
            "latest"
            "36.0.0"
            "35.0.0"
          ];
          includeEmulator = false;
          includeSystemImages = false;
          includeCmake = true;
          cmakeVersions = [ "3.22.1" ];
          includeNDK = true;
          ndkVersions = [ "27.1.12297006" ];
        };
        androidSdk = androidComposition.androidsdk;

        casks = with pkgs.brewCasks; [
          bettercapture
          bruno
          codex-app
          crossover
          ghostty
          helium-browser
          hiddenbar
          openusage
          pearcleaner
          shottr
          the-unarchiver
          vial
          xcodes-app

          (aerospace.overrideAttrs (oldAttrs: {
            # brew-nix uses the cask artifact path as the destination, which
            # leaves the app nested under AeroSpace-vX.Y.Z. Install the bundle
            # directly under Applications instead, while retaining the CLI.
            installPhase = ''
              runHook preInstall

              mkdir -p $out/Applications/AeroSpace.app $out/bin
              cp -R . $out/Applications/AeroSpace.app/
              install -m755 ../bin/aerospace $out/bin/aerospace

              runHook postInstall
            '';

            meta = oldAttrs.meta // {
              mainProgram = "aerospace";
            };
          }))
        ];
      in
      {
        home = {
          packages =
            with pkgs;
            [
              pi-coding-agent

              # inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.pi
              inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode
              inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.herdr

              nh

              jankyborders

              tmux
              rsync
              direnv
              pnpm
              (python3.withPackages (pythonPackages: [
                pythonPackages.pexpect
                pythonPackages.textual
              ]))

              podman
              podman-compose

              cocoapods
              androidSdk
              jdk

              nerd-fonts.symbols-only
              nerd-fonts.iosevka
            ]
            ++ casks;

        };
      }
    )
  ];

  config.bfmp.hm.hosts.cherubim.modules = [
    (
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          zsh

          bitwarden-cli
          mcporter

          hypridle
          hyprland
          hyprlock
          hyprpaper
          hyprpwcenter

          cliphist
          grim
          libnotify
          playerctl
          quickshell
          satty
          slurp
          wl-clipboard

          xdg-desktop-portal
          xdg-desktop-portal-gtk
          xdg-desktop-portal-hyprland

          peazip
          ungoogled-chromium
          vial

          podman
          podman-compose

          kdePackages.dolphin

          qt6.qtbase
          qt6.qtdeclarative
          qt6.qttools

          hanken-grotesk
          nerd-fonts.symbols-only
          nerd-fonts.victor-mono
          nerd-fonts.iosevka
        ];
      }
    )
  ];

  config.bfmp.hm.hosts.powers.modules = [
    (
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          zsh

          ncdu
        ];
      }
    )
  ];

  config.bfmp.hm.hosts.thronos.modules = [
    (
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          zsh
        ];
      }
    )
  ];
}
