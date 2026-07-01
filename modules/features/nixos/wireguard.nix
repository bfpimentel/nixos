{ ... }:

let
  wireguardPort = 51000;
  wireguardSubnet = "10.64.0.0/24";

  thronosAddress = "10.64.0.1/24";
  powersAddress = "10.64.0.2/32";
  powersLanSubnet = "10.22.4.0/24";

  mkClient =
    {
      publicKey,
      address,
      routes ? [ ],
    }:
    {
      inherit publicKey;
      allowedIPs = [ "${address}/32" ] ++ routes;
    };

  clientPeers = [
    (mkClient {
      publicKey = "j1jw7utTgzsueh42W0ESYQEawSPEZSJSsyzIP1w2CHU=";
      address = "10.64.0.10";
    })
    (mkClient {
      publicKey = "ioVFvdH7TJUB4ZE24JsTi1oOxu4KcEk0pWMI7qLnG0U=";
      address = "10.64.0.11";
    })
    (mkClient {
      publicKey = "nmRXqL2t7qsCBeNHyQH0GqWLqmOOkSwFFxyZjJ7FrGI=";
      address = "10.64.0.12";
    })
  ];
in
{
  config.bfmp.nixos.hosts.thronos.modules = [
    (
      { config, ... }:
      {
        networking = {
          firewall = {
            allowedUDPPorts = [ wireguardPort ];
            trustedInterfaces = [ "wg0" ];
          };

          wireguard.interfaces.wg0 = {
            ips = [ thronosAddress ];
            listenPort = wireguardPort;
            privateKeyFile = config.age.secrets.wireguard-thronos-private.path;
            peers = [
              (mkClient {
                publicKey = "Ptq7wPO0GGTMzXpP2po9H1v3vBX47a1QhIjvQc2Tqls=";
                address = "10.64.0.2";
                routes = [ powersLanSubnet ];
              })
            ]
            ++ clientPeers;
          };
        };
      }
    )
  ];

  config.bfmp.nixos.hosts.powers.modules = [
    (
      { config, ... }:
      {
        networking = {
          nat = {
            enable = true;
            externalInterface = "eno1";
            internalInterfaces = [ "wg0" ];
          };

          wireguard.interfaces.wg0 = {
            ips = [ powersAddress ];
            privateKeyFile = config.age.secrets.wireguard-powers-private.path;

            peers = [
              {
                publicKey = "BdQ+qBHljPx2rNTZQcn8FHNV7Toh44Egnz+nqDYqeGA=";
                allowedIPs = [ wireguardSubnet ];
                endpoint = "159.112.184.83:${toString wireguardPort}";
                persistentKeepalive = 25;
              }
            ];
          };
        };

        boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
      }
    )
  ];
}
