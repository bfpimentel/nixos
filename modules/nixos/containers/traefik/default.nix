{ config, vars, ... }:
let
  directories = [ "${vars.containersConfigRoot}/traefik" ];
  files = [ "${vars.containersConfigRoot}/traefik/acme.json" ];
in
{
  systemd.tmpfiles.rules =
    map (x: "d ${x} 0775 share share - -") directories
    ++ map (x: "f ${x} 0600 share share - -") files;

  virtualisation.oci-containers = {
    containers = {
      traefik = {
        image = "traefik:latest";
        autoStart = true;
        cmd = [
          "--api.insecure=true"
          "--providers.docker=true"
          "--providers.docker.exposedbydefault=false"
          "--entrypoints.web.address=:80"
          "--certificatesresolvers.letsencrypt.acme.dnschallenge=true"
          "--certificatesresolvers.letsencrypt.acme.dnschallenge.provider=cloudflare"
          "--certificatesresolvers.letsencrypt.acme.email=hello@bruno.so"
          # HTTP
          "--entrypoints.web.address=:80"
          "--entrypoints.web.http.redirections.entrypoint.to=websecure"
          "--entrypoints.web.http.redirections.entrypoint.scheme=https"
          "--entrypoints.websecure.address=:443"
          # HTTPS
          "--entrypoints.websecure.http.tls=true"
          "--entrypoints.websecure.http.tls.certResolver=letsencrypt"
          "--entrypoints.websecure.http.tls.domains[0].main=${vars.domain}"
          "--entrypoints.websecure.http.tls.domains[0].sans=*.${vars.domain}"

        ];
        extraOptions = [
          "--pull=newer"
          # Proxying Traefik itself
          "-l=traefik.enable=true"
          "-l=traefik.http.routers.traefik.rule=Host(`traefik.${vars.domain}`)"
          "-l=traefik.http.services.traefik.loadbalancer.server.port=8080"
          "-l=homepage.group=Services"
          "-l=homepage.name=Traefik"
          "-l=homepage.icon=traefik.svg"
          "-l=homepage.href=https://traefik.${vars.domain}"
          "-l=homepage.description=Reverse proxy"
          "-l=homepage.widget.type=traefik"
          "-l=homepage.widget.url=http://traefik:8080"
        ];
        ports = [
          "443:443"
          "80:80"
        ];
        environmentFiles = [ config.age.secrets.cloudflare.path ];
        volumes = [
          "/var/run/docker/docker.sock:/var/run/docker.sock:ro"
          "${vars.containersConfigRoot}/traefik/acme.json:/acme.json"
        ];
      };
    };
  };
}
