{
  config,
  lib,
  vars,
  pkgs,
  util,
  ...
}:

with lib;
let
  immichVersion = "v1.137.3";

  immichPaths =
    let
      root = "${vars.containersConfigRoot}/immich";
    in
    {
      volumes = {
        inherit root;
        machineLearning = "${root}/machine-learning";
      };
      mounts = {
        photos = vars.photosMountLocation;
      };
      postgres = "${root}/postgres";
    };

  puid = toString vars.defaultUserUID;
  pgid = toString vars.defaultUserGID;

  cfg = config.bfmp.containers.immich;
in
{
  options.bfmp.containers.immich = {
    enable = mkEnableOption "Enable Immich";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      immich-cli
    ];

    systemd.tmpfiles.rules =
      map (x: "d ${x} 0775 ${vars.defaultUser} ${vars.defaultUser} - -") (
        builtins.attrValues immichPaths.volumes
      )
      ++ map (x: "d ${x} 0775 postgres ${vars.defaultUser} - -") [ immichPaths.postgres ];

    virtualisation.oci-containers.containers = {
      immich-server = {
        image = "ghcr.io/immich-app/immich-server:${immichVersion}";
        autoStart = true;
        devices = [ "nvidia.com/gpu=all" ];
        dependsOn = [
          "immich-redis"
          "immich-postgres"
          "immich-machine-learning"
        ];
        networks = [ "local" ];
        volumes = [ "${immichPaths.mounts.photos}:/data" ];
        environmentFiles = [ config.age.secrets.immich.path ];
        environment = {
          PUID = puid;
          PGID = pgid;
          TZ = vars.timeZone;
          DB_HOSTNAME = "immich-postgres";
          DB_USERNAME = "postgres";
          DB_DATABASE_NAME = "immich";
          REDIS_HOSTNAME = "immich-redis";
        };
        labels = util.mkDockerLabels {
          id = "immich";
          name = "Immich";
          subdomain = "photos";
          port = 2283;
        };
      };

      immich-machine-learning = {
        image = "ghcr.io/immich-app/immich-machine-learning:${immichVersion}-cuda";
        autoStart = true;
        devices = [ "nvidia.com/gpu=all" ];
        user = "${puid}:${pgid}";
        networks = [ "local" ];
        volumes = [ "${immichPaths.volumes.machineLearning}:/cache" ];
        environmentFiles = [ config.age.secrets.immich.path ];
        environment = {
          DB_HOSTNAME = "immich-postgres";
          DB_DATABASE_NAME = "immich";
          DB_USERNAME = "postgres";
          REDIS_HOSTNAME = "immich-redis";
        };
        labels = {
          "glance.parent" = "immich";
          "glance.name" = "Machine Learning";
        };
      };

      immich-postgres = {
        image = "ghcr.io/immich-app/postgres:14-vectorchord0.3.0-pgvectors0.2.0";
        autoStart = true;
        networks = [ "local" ];
        volumes = [ "${immichPaths.postgres}:/var/lib/postgresql/data" ];
        environmentFiles = [ config.age.secrets.immich.path ];
        environment = {
          POSTGRES_DB = "immich";
          POSTGRES_USER = "postgres";
        };
        labels = {
          "glance.parent" = "immich";
          "glance.name" = "Postgres";
        };
      };

      immich-redis = {
        image = "redis";
        autoStart = true;
        extraOptions = [ "--pull=always" ];
        networks = [ "local" ];
        labels = {
          "glance.parent" = "immich";
          "glance.name" = "Redis";
        };
      };
    };
  };
}
