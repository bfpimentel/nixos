{ ... }:

{
  config.bfmp.nixos.hosts.powers.modules = [
    (
      { ... }:
      {
        systemd.tmpfiles.rules = [
          "d /mnt/mass/containers/baikal 0755 1000 1000 -"
          "d /mnt/mass/containers/baikal/config 0755 1000 1000 -"
          "d /mnt/mass/containers/baikal/data 0755 1000 1000 -"
        ];

        virtualisation.oci-containers.containers.baikal = {
          image = "docker.io/ckulka/baikal:latest";
          pull = "always";
          autoStart = true;
          ports = [ "7116:80" ];
          volumes = [
            "/mnt/mass/containers/baikal/config:/var/www/baikal/config"
            "/mnt/mass/containers/baikal/data:/var/www/baikal/Specific"
          ];
          labels = {
            "shady.name" = "baikal";
            "shady.url" = "https://dav.local.jalotopimentel.com";
          };
        };
      }
    )
  ];
}
