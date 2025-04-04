{
  config,
  lib,
  vars,
  ...
}:

with lib;
let
  tautulliPaths =
    let
      root = "${vars.containersConfigRoot}/tautulli";
    in
    {
      volumes = {
        inherit root;
      };
    };

  puid = toString vars.defaultUserUID;
  guid = toString vars.defaultUserGID;

  cfg = config.bfmp.containers.tautulli;
in
{
  options.bfmp.containers.tautulli = {
    enable = mkEnableOption "Enable Tautulli";
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = map (x: "d ${x} 0775 ${vars.defaultUser} ${vars.defaultUser} - -") (
      builtins.attrValues tautulliPaths.volumes
    );

    virtualisation.oci-containers.containers = {
      tautulli = {
        image = "ghcr.io/tautulli/tautulli";
        autoStart = true;
        extraOptions = [ "--pull=newer" ];
        volumes = [ "${tautulliPaths.volumes.root}:/config" ];
        environment = {
          TZ = vars.timeZone;
          PUID = puid;
          PGID = guid;
        };
        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.tautulli.rule" = "Host(`tautulli.${vars.domain}`)";
          "traefik.http.routers.tautulli.entryPoints" = "https";
          "traefik.http.services.tautulli.loadbalancer.server.port" = "8181";
          # Homepage
          "homepage.group" = "Monitoring";
          "homepage.name" = "Tautulli";
          "homepage.icon" = "tautulli.svg";
          "homepage.href" = "https://tautulli.${vars.domain}";
        };
      };
    };
  };
}
