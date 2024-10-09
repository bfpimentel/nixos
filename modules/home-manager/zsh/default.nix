{
  system,
  config,
  ...
}:

let
  systemSpecificRebuildCmd =
    if (system == "aarch64-darwin") then "darwin-rebuild" else "nixos-rebuild";
in
{
  programs.zsh = {
    enable = true;
    envExtra = ''
      ZDOTDIR="${config.home.homeDirectory}/.config/zsh"
      alias rnix="${systemSpecificRebuildCmd} switch --flake /etc/nixos --impure"
    '';
  };

  home.file.".config/zsh".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/modules/home-manager/zsh/config";
}
