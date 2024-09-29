{
  pkgs,
  inputs,
  ...
}:

{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    unzip
    fzf
    fd
    ripgrep
    pciutils
    tcpdump
    lm_sensors
    lazygit

    gcc
    cargo
    nodejs_22

    nil
    stylua
    bash-language-server
    yaml-language-server
    nixfmt-rfc-style

    podman-tui
    podman-compose

    immich-cli

    cudatoolkit

    inputs.agenix.packages."${system}".default
    inputs.home-manager.packages."${system}".default
  ];

  programs.zsh.enable = true;

  environment.pathsToLink = [ "/share/zsh" ];
}
