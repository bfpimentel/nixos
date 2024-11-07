{ vars, username, ... }:

let
  arrPaths = {
    volumes = {
      sonarr = "${vars.containersConfigRoot}/sonarr";
      radarr = "${vars.containersConfigRoot}/radarr";
      prowlarr = "${vars.containersConfigRoot}/prowlarr";
      bazarr = "${vars.containersConfigRoot}/bazarr";
    };
    mounts = {
      downloads = "${vars.mediaMountLocation}/downloads";
      movies = "${vars.mediaMountLocation}/movies";
      anime = "${vars.mediaMountLocation}/anime";
      shows = "${vars.mediaMountLocation}/shows";
    };
  };

  puid = toString vars.defaultUserUID;
  pgid = toString vars.defaultUserGID;
in
{
  systemd.tmpfiles.rules = map (x: "d ${x} 0775 ${username} ${username} - -") (
    builtins.attrValues arrPaths.volumes
  );

  virtualisation.oci-containers.containers = {
    sonarr = {
      image = "lscr.io/linuxserver/sonarr:develop";
      autoStart = true;
      extraOptions = [ "--pull=newer" ];
      volumes = [
        "${arrPaths.volumes.sonarr}:/config"
        "${arrPaths.mounts.downloads}:/downloads"
        "${arrPaths.mounts.anime}:/anime"
        "${arrPaths.mounts.shows}:/shows"
      ];
      environment = {
        TZ = vars.timeZone;
        PUID = puid;
        PGID = pgid;
        UMASK = "002";
      };
      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.sonarr.rule" = "Host(`sonarr.${vars.domain}`)";
        "traefik.http.routers.sonarr.middlewares" = "auth@file";
        "traefik.http.services.sonarr.loadbalancer.server.port" = "8989";
        # Homepage
        "homepage.group" = "Media";
        "homepage.name" = "Sonarr";
        "homepage.icon" = "sonarr.svg";
        "homepage.href" = "https://sonarr.${vars.domain}";
        "homepage.weight" = "10";
        "homepage.widget.type" = "sonarr";
        "homepage.widget.key" = "{{HOMEPAGE_VAR_SONARR_KEY}}";
        "homepage.widget.url" = "http://sonarr:8989";
      };
    };
    radarr = {
      image = "lscr.io/linuxserver/radarr:develop";
      autoStart = true;
      extraOptions = [ "--pull=newer" ];
      volumes = [
        "${arrPaths.volumes.radarr}:/config"
        "${arrPaths.mounts.downloads}:/downloads"
        "${arrPaths.mounts.movies}:/movies"
      ];
      environment = {
        TZ = vars.timeZone;
        PUID = puid;
        PGID = pgid;
        UMASK = "002";
      };
      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.radarr.rule" = "Host(`radarr.${vars.domain}`)";
        "traefik.http.routers.radarr.middlewares" = "auth@file";
        "traefik.http.services.radarr.loadbalancer.server.port" = "7878";
        # Homepage
        "homepage.group" = "Media";
        "homepage.name" = "Radarr";
        "homepage.icon" = "radarr.svg";
        "homepage.href" = "https://radarr.${vars.domain}";
        "homepage.weight" = "20";
        "homepage.widget.type" = "radarr";
        "homepage.widget.key" = "{{HOMEPAGE_VAR_RADARR_KEY}}";
        "homepage.widget.url" = "http://radarr:7878";
      };
    };
    bazarr = {
      image = "lscr.io/linuxserver/bazarr:latest";
      autoStart = true;
      extraOptions = [ "--pull=newer" ];
      volumes = [
        "${arrPaths.volumes.bazarr}:/config"
        "${arrPaths.mounts.movies}:/movies"
        "${arrPaths.mounts.anime}:/anime"
        "${arrPaths.mounts.shows}:/shows"
      ];
      environment = {
        TZ = vars.timeZone;
        PUID = puid;
        PGID = pgid;
        UMASK = "002";
      };
      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.bazarr.rule" = "Host(`bazarr.${vars.domain}`)";
        "traefik.http.routers.bazarr.middlewares" = "auth@file";
        "traefik.http.services.bazarr.loadbalancer.server.port" = "6767";
        # Homepage
        "homepage.group" = "Media";
        "homepage.name" = "Bazarr";
        "homepage.icon" = "bazarr.svg";
        "homepage.href" = "https://bazarr.${vars.domain}";
        "homepage.weight" = "30";
        "homepage.widget.type" = "bazarr";
        "homepage.widget.key" = "{{HOMEPAGE_VAR_BAZARR_KEY}}";
        "homepage.widget.url" = "http://bazarr:6767";
      };
    };
    prowlarr = {
      image = "lscr.io/linuxserver/prowlarr:latest";
      autoStart = true;
      extraOptions = [ "--pull=newer" ];
      volumes = [ "${arrPaths.volumes.prowlarr}:/config" ];
      environment = {
        TZ = vars.timeZone;
        PUID = puid;
        PGID = pgid;
        UMASK = "002";
      };
      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.prowlarr.rule" = "Host(`prowlarr.${vars.domain}`)";
        "traefik.http.routers.prowlarr.middlewares" = "auth@file";
        "traefik.http.services.prowlarr.loadbalancer.server.port" = "9696";
        # Homepage
        "homepage.group" = "Download Managers";
        "homepage.name" = "Prowlarr";
        "homepage.icon" = "prowlarr.svg";
        "homepage.href" = "https://prowlarr.${vars.domain}";
      };
    };
    flaresolverr = {
      image = "ghcr.io/flaresolverr/flaresolverr:latest";
      autoStart = true;
      extraOptions = [ "--pull=newer" ];
      environment = {
        TZ = vars.timeZone;
        LOG_LEVEL = "info";
        LOG_HTML = "false";
      };
    };
  };
}