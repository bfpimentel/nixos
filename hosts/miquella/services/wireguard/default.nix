{
  vars,
  config,
  pkgs,
  ...
}:

{
  networking.firewall.allowedUDPPorts = [ 51820 ];

  networking.wireguard = {
    enable = true;
    interfaces = {
      "${vars.wireguardInterface}" = {
        ips = [ "10.22.10.1/24" ];
        listenPort = 51820;
        privateKeyFile = config.age.secrets.wireguard-miquella.path;
        postSetup = ''
          ${pkgs.iptables}/bin/iptables -A FORWARD -i ${vars.wireguardInterface} -j ACCEPT;
          ${pkgs.iptables}/bin/iptables -A FORWARD -o ${vars.wireguardInterface} -j ACCEPT;
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o ${vars.networkInterface} -j MASQUERADE;
        '';
        postShutdown = ''
          ${pkgs.iptables}/bin/iptables -D FORWARD -i ${vars.wireguardInterface} -j ACCEPT;
          ${pkgs.iptables}/bin/iptables -D FORWARD -o ${vars.wireguardInterface} -j ACCEPT;
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o ${vars.networkInterface} -j MASQUERADE;
        '';
        peers = [
          {
            name = "malenia";
            publicKey = "DGIv16Ow92a2EzupVjD5K8wm9F0dicocvIuhKO9YbXQ=";
            allowedIPs = [
              "10.22.10.2/32"
              "10.22.4.0/24"
            ];
          }
          {
            name = "solaire";
            publicKey = "xMWICTNi398NCBj8DS3085R4jbqXZBSECyq3pWmx+U4=";
            allowedIPs = [ "10.22.10.3/32" ];
          }
          {
            name = "brunoS24U";
            publicKey = "YlprTAlepekMcelIeqV/JfDsQkAyo8TjpLLIvrvRrRE=";
            allowedIPs = [ "10.22.10.4/32" ];
          }
        ];
      };
    };
  };
}
