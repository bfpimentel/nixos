{
  vars,
  username,
  config,
  ...
}:
let
  beszelPaths =
    let
      root = "${vars.containersConfigRoot}/beszel";
    in
    {
      volumes = {
        inherit root;
      };
    };
in
{
  systemd.tmpfiles.rules = map (x: "d ${x} 0775 ${username} ${username} - -") (
    builtins.attrValues beszelPaths.volumes
  );

  virtualisation.oci-containers.containers = {
    beszel-agent = {
      image = "henrygd/beszel-agent:latest";
      autoStart = true;
      extraOptions = [ "--pull=newer" ];
      ports = [ "45876:45876" ];
      volumes = [ "/var/run/podman/podman.sock:/var/run/docker.sock" ];
      environment = {
        PORT = "45876";
        KEY = builtins.readFile config.age.secrets.beszel.path; # need to use anti-pattern here.
      };
    };
  };
}
