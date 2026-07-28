{ inputs, ... }:

{
  config.bfmp.nixos.sharedModules = [
    inputs.agenix.nixosModules.default
    (
      { config, pkgs, ... }:
      {
        environment.systemPackages = [ inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default ];
        age.identityPaths = [ "/home/bruno/.ssh/id_personal" ];
      }
    )
  ];

  config.bfmp.nixos.hosts.powers.modules = [
    (
      { config, ... }:
      {
        age.secrets = {
          # General
          nginx-env = {
            file = ../../../secrets/nginx-env.age;
            owner = "acme";
            group = "nginx";
            mode = "0440";
          };

          # Share
          share-credentials = {
            file = ../../../secrets/share-credentials.age;
            owner = "bruno";
            group = "bruno";
          };

          # Restic
          restic-env = {
            file = ../../../secrets/restic-env.age;
            mode = "0400";
          };
          restic-password = {
            file = ../../../secrets/restic-password.age;
            mode = "0400";
          };

          # Containers
          ghcr-token = {
            file = ../../../secrets/ghcr-token.age;
            owner = "root";
            group = "root";
            mode = "0400";
          };
          bap-env = {
            file = ../../../secrets/bap-env.age;
            owner = "bruno";
            group = "bruno";
          };
          immich-env = {
            file = ../../../secrets/immich-env.age;
            owner = "bruno";
            group = "bruno";
          };
          n8n-env = {
            file = ../../../secrets/n8n-env.age;
            owner = "bruno";
            group = "bruno";
          };
          searxng-env = {
            file = ../../../secrets/searxng-env.age;
            owner = "bruno";
            group = "bruno";
          };
          hass-env = {
            file = ../../../secrets/hass-env.age;
            owner = "bruno";
            group = "bruno";
          };
          gleb-env = {
            file = ../../../secrets/gleb-env.age;
            owner = "bruno";
            group = "bruno";
          };
          hermes-env = {
            file = ../../../secrets/hermes-env.age;
            owner = "bruno";
            group = "bruno";
            mode = "0400";
          };

          # WireGuard
          wireguard-powers-private = {
            file = ../../../secrets/wireguard-powers-private.age;
            owner = "systemd-network";
            group = "systemd-network";
            mode = "0400";
          };
        };
      }
    )
  ];

  config.bfmp.nixos.hosts.thronos.modules = [
    (
      { ... }:
      {
        age.secrets.wireguard-thronos-private = {
          file = ../../../secrets/wireguard-thronos-private.age;
          owner = "systemd-network";
          group = "systemd-network";
          mode = "0400";
        };
      }
    )
  ];
}
