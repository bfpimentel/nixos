let
  bruno = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHfTMOZqQ5tMiLG7GmhkhZrwgzpD2cPuQAuqAnG24qHw hello@bruno.so";
in
{
  # General
  "nginx-env.age".publicKeys = [ bruno ];

  # Share
  "share-credentials.age".publicKeys = [ bruno ];

  # Restic
  "restic-env.age".publicKeys = [ bruno ];
  "restic-password.age".publicKeys = [ bruno ];

  # Containers
  "bap-env.age".publicKeys = [ bruno ];
  "ghcr-token.age".publicKeys = [ bruno ];
  "gleb-env.age".publicKeys = [ bruno ];
  "hass-env.age".publicKeys = [ bruno ];
  "immich-env.age".publicKeys = [ bruno ];
  "n8n-env.age".publicKeys = [ bruno ];
  "searxng-env.age".publicKeys = [ bruno ];

  # Hermes
  "hermes-env.age".publicKeys = [ bruno ];
  "hermes-auth.age".publicKeys = [ bruno ];

  # WireGuard
  "wireguard-thronos-private.age".publicKeys = [ bruno ];
  "wireguard-powers-private.age".publicKeys = [ bruno ];
}
