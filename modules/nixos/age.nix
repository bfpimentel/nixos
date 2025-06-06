{ vars, ... }:

let
  username = vars.defaultUser;
in
{
  age = {
    identityPaths = [ "/home/${username}/.ssh/id_personal" ];

    secrets = {
      share.file = ../../secrets/share.age;
      cloudflare.file = ../../secrets/cloudflare.age;

      sonarr.file = ../../secrets/sonarr.age;
      radarr.file = ../../secrets/radarr.age;
      readarr.file = ../../secrets/readarr.age;
      bazarr.file = ../../secrets/bazarr.age;
      prowlarr.file = ../../secrets/prowlarr.age;
      vaultwarden.file = ../../secrets/vaultwarden.age;
      immich.file = ../../secrets/immich.age;
      audiobookshelf.file = ../../secrets/audiobookshelf.age;
      plex.file = ../../secrets/plex.age;
      freshrss.file = ../../secrets/freshrss.age;
      speedtest-tracker.file = ../../secrets/speedtest-tracker.age;
      authentik.file = ../../secrets/authentik.age;
      wordpress.file = ../../secrets/wordpress.age;
      jellyfin.file = ../../secrets/jellyfin.age;
      ollama-webui.file = ../../secrets/ollama-webui.age;
      paperless.file = ../../secrets/paperless.age;
      beszel.file = ../../secrets/beszel.age;
      hoarder.file = ../../secrets/hoarder.age;
      aliasvault.file = ../../secrets/aliasvault.age;

      apprise = {
        file = ../../secrets/apprise.age;
        mode = "600";
        owner = username;
        group = username;
      };
      ntfy = {
        file = ../../secrets/ntfy.age;
        mode = "600";
        owner = username;
        group = username;
      };
      telegram = {
        file = ../../secrets/telegram.age;
        mode = "600";
        owner = username;
        group = username;
      };

      tailscale-servers.file = ../../secrets/tailscale/servers.age;

      restic-env.file = ../../secrets/restic/env.age;
      restic-repo-containers.file = ../../secrets/restic/repo-containers.age;
      restic-password-containers.file = ../../secrets/restic/password-containers.age;
      restic-repo-photos.file = ../../secrets/restic/repo-photos.age;
      restic-password-photos.file = ../../secrets/restic/password-photos.age;

      nginx-vault = {
        file = ../../secrets/nginx/vault.age;
        mode = "600";
        owner = username;
        group = username;
      };
      nginx-baikal = {
        file = ../../secrets/nginx/baikal.age;
        mode = "600";
        owner = username;
        group = username;
      };

      wireguard-miquella.file = ../../secrets/wireguard/miquella.age;
      wireguard-malenia.file = ../../secrets/wireguard/malenia.age;
    };
  };
}
