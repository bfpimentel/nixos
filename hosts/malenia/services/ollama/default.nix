{
  config,
  lib,
  vars,
  pkgs,
  ...
}:

with lib;
let
  ollamaPaths =
    let
      root = "${vars.servicesConfigRoot}/ollama";
    in
    {
      volumes = {
        inherit root;
        data = "${root}/data";
        models = "${root}/models";
      };
    };

  cfg = config.bfmp.services.ollama;
in
{
  options.bfmp.services.ollama = {
    enable = mkEnableOption "Enable Ollama";
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = map (x: "d ${x} 0775 ${vars.defaultUser} ${vars.defaultUser} - -") (
      builtins.attrValues ollamaPaths.volumes
    );

    environment.systemPackages = with pkgs; [
      ollama
      ollama-cuda
    ];

    systemd.services.ollama.serviceConfig = {
      User = vars.defaultUser;
    };

    services.ollama = {
      enable = true;
      openFirewall = true;
      host = "0.0.0.0";
      port = 11434;
      acceleration = "cuda";
      home = ollamaPaths.volumes.data;
      models = ollamaPaths.volumes.models;
      loadModels = [
        "llama3.2:3b"
        "deepseek-r1:1.5b"
        "deepseek-r1:7b"
      ];
      environmentVariables = {
        OLLAMA_ORIGINS = "http://localhost:11434,https://ollama.${vars.domain}";
      };
    };
  };
}
