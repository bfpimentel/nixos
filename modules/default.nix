{ lib, ... }:

let
  isArchived = path:
    lib.elem "archive" (
      lib.splitString "/" (lib.removePrefix "${toString ./.}/" (toString path))
    );
  nixFiles = builtins.filter (
    path:
    lib.hasSuffix ".nix" (toString path)
    && builtins.baseNameOf (toString path) != "default.nix"
    && !isArchived path
  ) (lib.filesystem.listFilesRecursive ./.);
in
{
  imports = nixFiles;
}
