{ config, username, ... }:

{
  programs.zsh = {
    enable = true;
    envExtra = ''
      ZDOTDIR="/home/${username}/.config/zsh"
    '';
  };

  home.file.".config/zsh" = {
    source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/modules/home-manager/zsh/config";
  };
}
