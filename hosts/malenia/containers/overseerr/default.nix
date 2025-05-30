{
  config,
  lib,
  vars,
  util,
  ...
}:

with lib;
let
  overseerrPaths =
    let
      root = "${vars.containersConfigRoot}/overseerr";
    in
    {
      volumes = {
        inherit root;
      };
    };

  puid = toString vars.defaultUserUID;
  guid = toString vars.defaultUserGID;

  cfg = config.bfmp.containers.overseerr;
in
{
  options.bfmp.containers.overseerr = {
    enable = mkEnableOption "Enable Overseerr";
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = map (x: "d ${x} 0775 ${vars.defaultUser} ${vars.defaultUser} - -") (
      builtins.attrValues overseerrPaths.volumes
    );

    virtualisation.oci-containers.containers = {
      overseerr = {
        image = "lscr.io/linuxserver/overseerr:latest";
        autoStart = true;
        extraOptions = [ "--pull=newer" ];
        volumes = [ "${overseerrPaths.volumes.root}:/config" ];
        environment = {
          TZ = vars.timeZone;
          PORT = "5055";
          LOG_LEVEL = "debug";
          PUID = puid;
          GUID = guid;
        };
        labels = util.mkDockerLabels {
          id = "overseerr";
          name = "Overseerr";
          subdomain = "request";
          port = 5055;
        };
      };
    };
  };
}
