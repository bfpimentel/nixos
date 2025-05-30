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
  traefikPaths =
    let
      settingsFormat = pkgs.formats.yaml { };
      root = "${vars.containersConfigRoot}/traefik";
    in
    {
      volumes = {
        inherit root;
      };
      files = {
        acme = "${root}/acme.json";
      };
      generated = {
        config = settingsFormat.generate "config.yml" ((import ./config/config.nix) vars);
        dynamic = settingsFormat.generate "dynamic.yml" ((import ./config/dynamic.nix) vars);
      };
    };

  cfg = config.bfmp.containers.traefik;
in
{
  options.bfmp.containers.traefik = {
    enable = mkEnableOption "Enable Traefik";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    systemd.tmpfiles.rules =
      map (x: "d ${x} 0775 ${vars.defaultUser} ${vars.defaultUser} - -") (
        builtins.attrValues traefikPaths.volumes
      )
      ++ map (x: "f ${x} 0600 ${vars.defaultUser} ${vars.defaultUser} - -") (
        builtins.attrValues traefikPaths.files
      );

    virtualisation.oci-containers.containers = {
      traefik = {
        image = "traefik:latest";
        autoStart = true;
        extraOptions = [ "--pull=newer" ];
        ports = [
          "443:443"
          "80:80"
        ];
        volumes = [
          "/var/run/podman/podman.sock:/var/run/docker.sock:ro"
          "${traefikPaths.files.acme}:/acme.json"
          "${traefikPaths.generated.config}:/traefik.yml:ro"
          "${traefikPaths.generated.dynamic}:/dynamic.yml:ro"
        ];
        environmentFiles = [ config.age.secrets.cloudflare.path ];
        labels =
          util.mkDockerLabels {
            id = "traefik";
            name = "Traefik";
            subdomain = "traefik";
            port = 8080;
          }
          // {
            "traefik.http.routers.traefik.service" = "api@internal";
          };
      };
    };
  };
}
