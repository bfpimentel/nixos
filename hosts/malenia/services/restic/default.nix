{
  config,
  lib,
  vars,
  pkgs,
  ...
}:

with lib;
let
  backupNotifications = {
    restic-backups-photos-failure = "Backup de fotos falhou!";
    restic-backups-photos-success = "Backup de fotos feito com sucesso!";
    restic-backups-containers-failure = "Backup de containers falhou!";
    restic-backups-containers-success = "Backup de containers feito com sucesso!";
  };

  cfg = config.bfmp.services.restic;
in
{
  options.bfmp.services.restic = {
    enable = mkEnableOption "Enable Restic Backups";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      restic
    ];

    systemd.services =
      {
        restic-backups-podman-stop = {
          enable = true;
          serviceConfig = {
            Type = "oneshot";
          };
          script = ''${pkgs.systemd}/bin/systemctl stop podman-*'';
        };

        restic-backups-podman-start = {
          enable = true;
          serviceConfig = {
            Type = "oneshot";
          };
          script = ''${pkgs.systemd}/bin/systemctl start --no-block --all "podman-*"'';
        };

        restic-backups-photos = {
          requires = [ "restic-backups-podman-stop.service" ];
          after = [ "restic-backups-podman-stop.service" ];
          onFailure = [
            "restic-backups-podman-start.service"
            "restic-backups-photos-failure.service"
          ];
          onSuccess = [
            "restic-backups-podman-start.service"
            "restic-backups-photos-success.service"
          ];
        };

        restic-backups-containers = {
          requires = [ "restic-backups-podman-stop.service" ];
          after = [ "restic-backups-podman-stop.service" ];
          onFailure = [
            "restic-backups-podman-start.service"
            "restic-backups-containers-failure.service"
          ];
          onSuccess = [
            "restic-backups-podman-start.service"
            "restic-backups-containers-success.service"
          ];
        };
      }
      // mapAttrs' (
        name: message:
        attrsets.nameValuePair name {
          enable = true;
          serviceConfig = {
            Type = "oneshot";
            User = vars.defaultUser;
          };
          script = ''
            sleep 60
            ${pkgs.apprise}/bin/apprise --config=${config.age.secrets.apprise.path} \
              --tag="telegram" \
              --title=":computer: Servidor" \
              --body="${message}"
          '';
        }
      ) backupNotifications;

    services.restic.backups = {
      photos = {
        initialize = true;

        environmentFile = config.age.secrets.restic-env.path;
        repositoryFile = config.age.secrets.restic-repo-photos.path;
        passwordFile = config.age.secrets.restic-password-photos.path;

        paths = [ vars.photosMountLocation ];

        exclude = [
          "${vars.containersConfigRoot}/whisper"
        ];

        timerConfig = {
          OnCalendar = "04:00";
        };

        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 2"
        ];
      };
      containers = {
        initialize = true;

        environmentFile = config.age.secrets.restic-env.path;
        repositoryFile = config.age.secrets.restic-repo-containers.path;
        passwordFile = config.age.secrets.restic-password-containers.path;

        paths = [
          vars.containersConfigRoot
          vars.servicesConfigRoot
        ];

        exclude = [
          "${vars.servicesConfigRoot}/ollama/models"
        ];

        timerConfig = {
          OnCalendar = "04:00";
        };

        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 2"
        ];
      };
    };
  };
}
