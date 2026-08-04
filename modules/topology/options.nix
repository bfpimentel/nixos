{ lib, ... }:

let
  inherit (lib) mkOption;
  types = lib.types;
in
{
  options.bfmp = {
    hm = {
      overlays = mkOption {
        type = types.listOf types.raw;
        default = [ ];
      };

      sharedModules = mkOption {
        type = types.listOf types.deferredModule;
        default = [ ];
      };

      hosts = mkOption {
        type = types.attrsOf (
          types.submodule {
            options = {
              arch = mkOption {
                type = types.str;
              };

              modules = mkOption {
                type = types.listOf types.deferredModule;
                default = [ ];
              };
            };
          }
        );
        default = { };
      };
    };

    darwin = {
      sharedModules = mkOption {
        type = types.listOf types.deferredModule;
        default = [ ];
      };

      hosts = mkOption {
        type = types.attrsOf (
          types.submodule {
            options.modules = mkOption {
              type = types.listOf types.deferredModule;
              default = [ ];
            };
          }
        );
        default = { };
      };
    };

    nixos = {
      sharedModules = mkOption {
        type = types.listOf types.deferredModule;
        default = [ ];
      };

      hosts = mkOption {
        type = types.attrsOf (
          types.submodule {
            options.modules = mkOption {
              type = types.listOf types.deferredModule;
              default = [ ];
            };
          }
        );
        default = { };
      };
    };
  };
}
