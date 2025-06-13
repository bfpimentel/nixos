{
  config,
  vars,
  homeManagerConfig,
  pkgs,
  ...
}:

let
  systemSpecificExtras =
    if (vars.system == "aarch64-darwin") then
      ''
        alias rnix="sudo darwin-rebuild switch --flake /private/etc/nixos --impure"
        eval "$(direnv hook zsh)"
      ''
    else
      ''
        alias rnix="sudo nixos-rebuild switch --flake /etc/nixos --impure"
      '';
in
{
  programs.zsh = {
    enable = true;
    envExtra =
      ''
        source ${pkgs.antigen}/share/antigen/antigen.zsh
        ZDOTDIR="${config.home.homeDirectory}/.config/zsh"
      ''
      + systemSpecificExtras;
  };

  home.file.".config/zsh".source = homeManagerConfig.linkSharedApp config "zsh";
}
