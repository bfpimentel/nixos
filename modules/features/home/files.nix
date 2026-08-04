{ ... }:

{
  config.bfmp.hm.sharedModules = [
    (
      {
        pkgs,
        util,
        ...
      }:
      let
        inherit (util) mapAbsolute mapDotfiles;

        zshEnv = /* bash */ ''
          export XDG_CONFIG_HOME="$HOME/.config"
          export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
        '';
      in
      {
        home.file = {
          "Documents/Vial".source = mapAbsolute "misc/vial";
          "Documents/Wallpapers".source = mapAbsolute "misc/wallpapers";
          ".local/share/antidote".source = "${pkgs.antidote}/share/antidote";
          ".zshenv".text = zshEnv;
        }
        // mapDotfiles ([
          "git"
          "ghostty"
          "lazygit"
          "nvim"
          "opencode"
          "tmux"
          "zsh"
        ]);
      }
    )
  ];

  config.bfmp.hm.hosts.seraphim.modules = [
    (
      { util, ... }:
      let
        inherit (util) mapDotfiles;
      in
      {
        home.file =
          { }
          // mapDotfiles ([
            "aerospace"
            "borders"
            "herdr"
            "pi"
            "tuna"
          ]);
      }
    )
  ];

  config.bfmp.hm.hosts.cherubim.modules = [
    (
      { util, pkgs, ... }:
      let
        inherit (util) mapAbsolute mapDotfiles;
      in
      {
        home.file = {
          ".local/share/applications".source = mapAbsolute "dotfiles/applications";
        }
        // mapDotfiles ([
          "hypr"
          "quickshell"
          "sunshine"
        ]);

        services.udiskie = {
          enable = true;
          settings = {
            program_options = {
              file_manager = "${pkgs.kdePackages.dolphin}/bin/dolphin";
            };
          };
        };
      }
    )
  ];
}
