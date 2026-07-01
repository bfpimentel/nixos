{ ... }:

{
  config.bfmp.nixos.hosts.powers.modules = [
    (
      { util, ... }:
      {
        systemd.tmpfiles.rules = [
          "d /mnt/mass/containers/calibre-web 0755 1000 1000 -"
          "d /mnt/mass/containers/calibre-web/config 0755 1000 1000 -"
          "d /mnt/mass/containers/calibre-web/data 0755 1000 1000 -"
        ];

        virtualisation.oci-containers.containers.calibre-web = {
          image = "lscr.io/linuxserver/calibre-web:latest";
          pull = "always";
          autoStart = true;
          environment = {
            PUID = "1000";
            PGID = "1000";
            TZ = "America/Sao_Paulo";
          };
          ports = [ "8083:8083" ];
          volumes = [
            "/mnt/mass/containers/calibre-web/config:/config"
            "/mnt/mass/containers/calibre-web/data:/data"
            "/mnt/share/media/ebooks:/books"
          ];
          labels = {
            "shady.name" = "calibre-web";
            "shady.url" = "https://books.local.jalotopimentel.com";
          };
        };

        systemd.services.podman-calibre-web = util.mkContainerWaitMount [
          "mnt-share-media.automount"
        ];
      }
    )
  ];
}
