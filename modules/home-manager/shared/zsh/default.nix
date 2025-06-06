{
  config,
  vars,
  homeManagerConfig,
  ...
}:

let
  systemSpecificRebuildCmd =
    if (vars.system == "aarch64-darwin") then
      "darwin-rebuild switch --flake /private/etc/nixos"
    else
      "nixos-rebuild switch --flake /etc/nixos";
in
{
  programs.zsh = {
    enable = true;
    envExtra = ''
      ZDOTDIR="${config.home.homeDirectory}/.config/zsh"
      alias rnix="sudo ${systemSpecificRebuildCmd} --impure"
    '';
  };

  home.file.".config/zsh".source = homeManagerConfig.linkSharedApp config "zsh";
}
