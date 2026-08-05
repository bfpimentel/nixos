{ ... }:

{
  config.bfmp.nixos.hosts.powers.modules = [
    (
      {
        config,
        pkgs,
        util,
        ...
      }:
      {
        systemd.tmpfiles.rules = [
          "d /mnt/mass/containers/immich 0755 1000 1000 -"
          "d /mnt/mass/containers/immich/postgres 0755 999 root -"
        ];

        virtualisation.oci-containers.containers = {
          immich-server = {
            image = "ghcr.io/immich-app/immich-server:v3";
            pull = "always";
            autoStart = true;
            dependsOn = [
              "immich-redis"
              "immich-postgres"
            ];
            devices = [ "/dev/dri:/dev/dri" ];
            environmentFiles = [ config.age.secrets.immich-env.path ];
            ports = [ "2283:2283" ];
            volumes = [
              "/mnt/share/photos:/data"
              "/etc/localtime:/etc/localtime:ro"
            ];
            labels = {
              "shady.name" = "immich";
              "shady.url" = "https://photos.local.jalotopimentel.com";
            };
          };

          immich-machine-learning = {
            image = "ghcr.io/immich-app/immich-machine-learning:v3";
            pull = "always";
            autoStart = true;
            environmentFiles = [ config.age.secrets.immich-env.path ];
            volumes = [ "model-cache:/cache" ];
          };

          immich-redis = {
            image = "docker.io/valkey/valkey:9@sha256:546304417feac0874c3dd576e0952c6bb8f06bb4093ea0c9ca303c73cf458f63";
            pull = "always";
            autoStart = true;
          };

          immich-postgres = {
            image = "ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0";
            pull = "always";
            autoStart = true;
            extraOptions = [
              "--shm-size=128mb"
            ];
            environmentFiles = [ config.age.secrets.immich-env.path ];
            volumes = [ "/mnt/mass/containers/immich/postgres:/var/lib/postgresql/data" ];
          };
        };

        systemd.services.podman-immich-server = util.mkContainerWaitMount [
          "mnt-share-photos.automount"
        ];
      }
    )
  ];
}
