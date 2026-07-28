{ ... }:

{
  config.bfmp.nixos.hosts.powers.modules = [
    (
      { config, ... }:
      let
        registryLogin = {
          registry = "ghcr.io";
          username = "bfpimentel";
          passwordFile = config.age.secrets.ghcr-token.path;
        };
      in
      {
        systemd.tmpfiles.rules = [
          "d /mnt/mass/containers/gleb 0755 1000 1000 -"
          "d /mnt/mass/containers/gleb/data 0755 1000 1000 -"
        ];

        virtualisation.oci-containers.containers = {
          gleb-server = {
            image = "ghcr.io/bfpimentel/gleb-server:latest";
            login = registryLogin;
            pull = "always";
            autoStart = true;
            environmentFiles = [ config.age.secrets.gleb-env.path ];
            ports = [ "9001:3001" ];
            volumes = [ "/mnt/mass/containers/gleb/data:/app/data" ];
          };

          gleb-app = {
            image = "ghcr.io/bfpimentel/gleb-app:latest";
            login = registryLogin;
            pull = "always";
            autoStart = true;
            dependsOn = [ "gleb-server" ];
            ports = [ "9000:80" ];
            environment = {
              GLEB_SERVER_URL = "https://gleb-server.local.jalotopimentel.com";
            };
            labels = {
              "shady.name" = "gleb";
              "shady.url" = "https://gleb.local.jalotopimentel.com";
            };
          };
        };
      }
    )
  ];
}
