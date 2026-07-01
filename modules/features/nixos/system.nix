{ ... }:

{
  config.bfmp.nixos.sharedModules = [
    (
      { pkgs, ... }:
      {
        system.stateVersion = "25.11";

        boot = {
          kernelPackages = pkgs.linuxPackages_latest;
          loader.systemd-boot.enable = true;
          loader.efi.canTouchEfiVariables = true;
          kernelModules = [ "uinput" ];
        };

        time.timeZone = "America/Sao_Paulo";

        programs = {
          nh = {
            enable = true;
            clean = {
              enable = true;
              extraArgs = "--keep 5";
            };
          };

          nix-ld.enable = true;
        };
      }
    )
  ];

  config.bfmp.nixos.hosts.cherubim.modules = [
    (
      { pkgs, ... }:
      {
        boot.kernelModules = [ "uinput" ];

        hardware.graphics = {
          enable = true;
          enable32Bit = true;
        };

        security = {
          polkit.enable = true;
          rtkit.enable = true;
        };

        services = {
          pulseaudio.enable = false;
          tailscale.enable = true;
          avahi.publish.userServices = true;
          udisks2.enable = true;
          pipewire = {
            enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
            extraConfig.pipewire = {
              "98-crackling-fix" = {
                "context.properties" = {
                  "default.clock.quantum" = 1024;
                  "default.clock.min-quantum" = 1024;
                  "default.clock.max-quantum" = 8192;
                };
              };
            };
          };
        };
      }
    )
  ];

  config.bfmp.nixos.hosts.powers.modules = [
    ({ ... }: { })
  ];

  config.bfmp.nixos.hosts.thronos.modules = [
    ({ ... }: { })
  ];
}
