{ vars, username, ... }:

let
  qbtPaths =
    let
      root = "${vars.containersConfigRoot}/qbittorrent";
    in
    {
      volumes = {
        inherit root;
        config = "${root}/config";
        themes = "${root}/themes";
      };
      mounts = {
        downloads = "${vars.mediaMountLocation}/downloads";
      };
    };

  puid = toString vars.defaultUserUID;
  pgid = toString vars.defaultUserGID;
in
{
  systemd.tmpfiles.rules = map (x: "d ${x} 0775 ${username} ${username} - -") (
    builtins.attrValues qbtPaths.volumes
  );

  networking.firewall.allowedTCPPorts = [ 6881 ];
  networking.firewall.allowedUDPPorts = [ 6881 ];

  virtualisation.oci-containers.containers = {
    qbittorrent = {
      image = "lscr.io/linuxserver/qbittorrent:latest";
      autoStart = true;
      extraOptions = [ "--pull=newer" ];
      ports = [
        "127.0.0.1:6881:6881"
        "127.0.0.1:6881:6881/udp"
      ];
      volumes = [
        "${qbtPaths.volumes.config}:/config"
        "${qbtPaths.volumes.themes}:/themes"
        "${qbtPaths.mounts.downloads}:/downloads"
      ];
      environment = {
        TZ = vars.timeZone;
        PUID = puid;
        PGID = pgid;
        UMASK = "002";
        TORRENTING_PORT = "6881";
        WEBUI_PORT = "8080";
      };
      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.qbittorrent.rule" = "Host(`torrent.${vars.domain}`)";
        "traefik.http.routers.qbittorrent.entryPoints" = "https";
        "traefik.http.routers.qbittorrent.service" = "qbittorrent";
        "traefik.http.services.qbittorrent.loadbalancer.server.port" = "8080";
        # Homepage
        "homepage.group" = "Download Managers";
        "homepage.name" = "Qbittorrent";
        "homepage.icon" = "qbittorrent.svg";
        "homepage.href" = "https://torrent.${vars.domain}";
      };
    };
  };
}