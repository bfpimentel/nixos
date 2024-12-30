{ vars, config, ... }:

{
  networking.firewall.allowedUDPPorts = [ 51820 ];

  networking.wireguard = {
    enable = true;
    interfaces = {
      "${vars.wireguardInterface}" = {
        ips = [ "10.22.10.2/24" ];
        listenPort = 51820;
        privateKeyFile = config.age.secrets.wireguard-malenia.path;
        peers = [
          {
            name = "miquella";
            publicKey = "foEvCoTUel5bw8+M+8zl3Vgoq598BC6ff+xAHj0+knA=";
            endpoint = "vpn.luana.casa:51820";
            allowedIPs = [ "10.22.10.2" "10.22.4.0/24" ];
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };
}
