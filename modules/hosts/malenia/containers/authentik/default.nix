{
  config,
  lib,
  vars,
  util,
  ...
}:

with lib;
let
  authentikPaths =
    let
      root = "${vars.containersConfigRoot}/authentik";
    in
    {
      volumes = {
        inherit root;
        media = "${root}/media";
        templates = "${root}/templates";
        certs = "${root}/certs";
      };
      postgres = "${root}/db";
    };

  cfg = config.bfmp.containers.authentik;
in
{
  options.bfmp.containers.authentik = {
    enable = mkEnableOption "Enable Authentik";
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules =
      map (x: "d ${x} 0775 ${vars.defaultUser} ${vars.defaultUser} - -") (
        builtins.attrValues authentikPaths.volumes
      )
      ++ map (x: "d ${x} 0775 postgres ${vars.defaultUser} - -") [ authentikPaths.postgres ];

    virtualisation.oci-containers.containers = {
      authentik-server = {
        image = "ghcr.io/goauthentik/server:2025.6.2";
        autoStart = true;
        extraOptions = [ "--pull=always" ];
        cmd = [ "server" ];
        dependsOn = [
          "authentik-db"
          "authentik-redis"
        ];
        networks = [ "local" ];
        volumes = [
          "${authentikPaths.volumes.media}:/media"
          "${authentikPaths.volumes.templates}:/templates"
        ];
        environmentFiles = [ config.age.secrets.authentik.path ];
        environment = {
          AUTHENTIK_REDIS__HOST = "authentik-redis";
          AUTHENTIK_POSTGRESQL__HOST = "authentik-db";
          AUTHENTIK_POSTGRESQL__USER = "authentik";
          AUTHENTIK_POSTGRESQL__NAME = "authentik";
        };
        labels = util.mkDockerLabels {
          id = "authentik";
          name = "Authentik";
          subdomain = "auth";
          port = 9000;
        };
      };
      authentik-worker = {
        image = "ghcr.io/goauthentik/server:2025.6.2";
        autoStart = true;
        extraOptions = [ "--pull=always" ];
        cmd = [ "worker" ];
        networks = [ "local" ];
        dependsOn = [
          "authentik-db"
          "authentik-redis"
        ];
        volumes = [
          "${authentikPaths.volumes.media}:/media"
          "${authentikPaths.volumes.templates}:/templates"
          "${authentikPaths.volumes.certs}:/certs"
        ];
        environmentFiles = [ config.age.secrets.authentik.path ];
        environment = {
          AUTHENTIK_REDIS__HOST = "authentik-redis";
          AUTHENTIK_POSTGRESQL__HOST = "authentik-db";
          AUTHENTIK_POSTGRESQL__USER = "authentik";
          AUTHENTIK_POSTGRESQL__NAME = "authentik";
        };
        labels = {
          "glance.parent" = "authentik";
          "glance.name" = "Worker";
        };
      };
      authentik-db = {
        image = "docker.io/library/postgres:16-alpine";
        autoStart = true;
        extraOptions = [ "--pull=always" ];
        networks = [ "local" ];
        volumes = [ "${authentikPaths.postgres}:/var/lib/postgresql/data" ];
        environmentFiles = [ config.age.secrets.authentik.path ];
        environment = {
          POSTGRES_USER = "authentik";
          POSTGRES_DB = "authentik";
        };
        labels = {
          "glance.parent" = "authentik";
          "glance.name" = "Postgres";
        };
      };
      authentik-redis = {
        image = "docker.io/library/redis:alpine";
        autoStart = true;
        extraOptions = [ "--pull=always" ];
        networks = [ "local" ];
        labels = {
          "glance.parent" = "authentik";
          "glance.name" = "Redis";
        };
      };
    };
  };
}
