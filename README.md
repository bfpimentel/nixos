# bfpimentel's nixOS configs

This repo is for my personal NixOS machines and Nix Package Manager. It's public for demo purposes and I'm happy to answer any questions, but don't expect me to be fast on answering them.

The following machines are being configured:
1. *malenia*: Homelab (x64) powered by NixOS.
2. *miquella*: OCI (Arm) machine powered by NixOS.
3. *solaire*: MacOS (Darwin) machine powered by NixOS package manager for environment and user configuration.

## Darwin Setup

1. Install Nix through Determinate Nix Installer
    ```curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install```
2. Update flake
    ```cd /etc/nixos && nix flake update```
3. Rebuild
    ```cd /etc/nixos && nix run nix-darwin/master#darwin-rebuild -- switch --flake .#<host_name>```

## Structure

```
root
|-- modules
    |-- shared
        |-- nixos
        |-- darwin
    |-- hosts
        |-- malenia
        |-- miquella
        |-- solaire
    |-- home-manager
        |-- shared
        |-- hosts
            |-- malenia
            |-- miquella
            |-- solaire
```
