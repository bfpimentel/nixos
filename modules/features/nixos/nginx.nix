{ ... }:

let
  acmeHost = "local.jalotopimentel.com";

  extraConfig = ''
    client_max_body_size 0;
    proxy_request_buffering off;
    proxy_max_temp_file_size 0;
  '';

  mkLocalProxyHost = port: {
    useACMEHost = acmeHost;
    forceSSL = true;

    locations."/" = {
      proxyPass = "http://10.22.4.6:${toString port}";
      proxyWebsockets = true;
      extraConfig = extraConfig;
    };
  };

  mkRemoteProxyHost = address: {
    useACMEHost = acmeHost;
    forceSSL = true;

    locations."/" = {
      proxyPass = "http://${address}";
      proxyWebsockets = true;
      extraConfig = extraConfig;
    };
  };
in
{
  config.bfmp.nixos.hosts.powers.modules = [
    (
      { config, ... }:
      {
        security.acme = {
          acceptTerms = true;
          defaults.email = "hello@bruno.so";

          certs.${acmeHost} = {
            domain = "*.${acmeHost}";
            extraDomainNames = [ acmeHost ];
            dnsProvider = "cloudflare";
            group = "nginx";
            environmentFile = config.age.secrets.nginx-env.path;
          };
        };

        services.nginx = {
          enable = true;
          recommendedGzipSettings = true;
          recommendedOptimisation = true;
          recommendedProxySettings = true;
          recommendedTlsSettings = true;

          virtualHosts = {
            # Local
            "bap-server.${acmeHost}" = mkLocalProxyHost 6223;
            "bap.${acmeHost}" = mkLocalProxyHost 6224;
            "books.${acmeHost}" = mkLocalProxyHost 8083;
            "dash.${acmeHost}" = mkLocalProxyHost 7112;
            "dav.${acmeHost}" = mkLocalProxyHost 7116;
            "drip.${acmeHost}" = mkLocalProxyHost 7123;
            "hass-sync.${acmeHost}" = mkLocalProxyHost 8334;
            "hass.${acmeHost}" = mkLocalProxyHost 8333;
            "hermes.${acmeHost}" = mkLocalProxyHost 9119;
            "jobs.${acmeHost}" = mkLocalProxyHost 3005;
            "logs.${acmeHost}" = mkLocalProxyHost 7113;
            "media.${acmeHost}" = mkLocalProxyHost 8096;
            "photos.${acmeHost}" = mkLocalProxyHost 2283;
            "satellite.${acmeHost}" = mkLocalProxyHost 6333;
            "search.${acmeHost}" = mkLocalProxyHost 7114;
            "torrent.${acmeHost}" = mkLocalProxyHost 6882;
            "trips.${acmeHost}" = mkLocalProxyHost 3006;

            # Remote
            "dns.${acmeHost}" = mkRemoteProxyHost "10.22.4.7:3000";
            "home.${acmeHost}" = mkRemoteProxyHost "10.22.4.3:8123";
            "storage.${acmeHost}" = mkRemoteProxyHost "10.22.4.4:2000";
            "streaming.${acmeHost}" = mkRemoteProxyHost "10.22.4.10:47990";
          };
        };

        networking.firewall.allowedTCPPorts = [
          80
          443
        ];
      }
    )
  ];
}
