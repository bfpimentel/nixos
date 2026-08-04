{ inputs, ... }:

{
  config.bfmp.darwin.sharedModules = [
    inputs.determinate.darwinModules.default
    (
      { ... }:
      {
        determinateNix.enable = true;
        system.stateVersion = 6;
      }
    )
  ];

  config.bfmp.darwin.hosts.seraphim.modules = [
    (
      { ... }:
      {
        networking.hostName = "seraphim";
        nixpkgs.hostPlatform = "aarch64-darwin";
        system.primaryUser = "bruno";
        users.users.bruno.home = "/Users/bruno";
      }
    )
  ];
}
