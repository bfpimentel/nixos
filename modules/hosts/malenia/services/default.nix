{ ... }:

let
  configureForGaming = true;
in
{
  imports = [
    ./displaymanager
    ./gaming
    ./ollama
    ./restic
    ./streaming
    ./wireguard
  ];

  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
  };

  bfmp.services = {
    displayManager = {
      enable = configureForGaming;
      enableHyprland = true;
    };
    gaming.enable = configureForGaming;
    ollama.enable = false;
    restic.enable = true;
    streaming = {
      enable = configureForGaming;
      enableApollo = false;
    };
    wireguard = {
      enable = false;
      isServer = false;
    };
  };
}
