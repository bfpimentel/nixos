{
  config,
  lib,
  inputs,
  ...
}:

let
  cfg = config.bfmp;

  hmNixPkgsModule =

    {
      nixpkgs = {
        overlays = cfg.hm.overlays;
        config = {
          allowUnfree = true;
          android_sdk.accept_license = true;
        };
      };
    };
in
{
  flake = {
    homeConfigurations = lib.mapAttrs' (
      hostname: hostConfig:
      lib.nameValuePair "bruno@${hostname}" (
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages.${hostConfig.arch};
          modules = [ hmNixPkgsModule ] ++ cfg.hm.sharedModules ++ hostConfig.modules;
        }
      )
    ) cfg.hm.hosts;

    nixosConfigurations = lib.mapAttrs (
      hostname: hostConfig:
      let
        homeHostConfig = cfg.hm.hosts.${hostname} or { modules = [ ]; };
      in
      inputs.nixpkgs.lib.nixosSystem {
        modules = [
          hmNixPkgsModule
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.bruno.imports = cfg.hm.sharedModules ++ homeHostConfig.modules;
            };
          }
        ]
        ++ cfg.nixos.sharedModules
        ++ hostConfig.modules;
      }
    ) cfg.nixos.hosts;
  };
}
