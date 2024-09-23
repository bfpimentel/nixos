{ username, ... }:

{
  age = {
    identityPaths = [ "/home/${username}/.ssh/id_personal" ];
    secrets = {
      share.file = ../../secrets/share.age;
      cloudflare.file = ../../secrets/cloudflare.age;
      sonarr.file = ../../secrets/sonarr.age;
      radarr.file = ../../secrets/radarr.age;
      bazarr.file = ../../secrets/bazarr.age;
      vaultwarden.file = ../../secrets/vaultwarden.age;
      immich.file = ../../secrets/immich.age;
      plex.file = ../../secrets/plex.age;
      speedtest-tracker.file = ../../secrets/speedtest-tracker.age;
      authentik.file = ../../secrets/authentik.age;
      tailscale-malenia.file = ../../secrets/tailscale-malenia.age;
      tailscale-containers.file = ../../secrets/tailscale-containers.age;
    };
  };
}
