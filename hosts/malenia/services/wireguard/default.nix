{ vars, config, pkgs, ... }:

{
  networking.firewall.allowedUDPPorts = [ 51820 ];

  networking.wireguard = {
    enable = true;
    interfaces = {
      "${vars.wireguardInterface}" = {
        ips = [ "10.22.10.2/24" ];
        listenPort = 51820;
        privateKeyFile = config.age.secrets.wireguard.path;
        peers = [
          {
            name = "solaire";
            publicKey = "DGIv16Ow92a2EzupVjD5K8wm9F0dicocvIuhKO9YbXQ=";
            endpoint = "vpn.luana.casa:51820";
            allowedIPs = [ "0.0.0.0/0" ];
            persistentKeepAlive = 25;
          }
        ];
      };
    };
  };
}
