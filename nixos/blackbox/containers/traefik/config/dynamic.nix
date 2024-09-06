ip: domain: {
  http = {
    routers = {
      glances = {
        entryPoints = [
          "https"
          "http"
        ];
        rule = "Host(`glances.${domain}`)";
        middlewares = [ "https-redirect" ];
        tls = {
          certResolver = "cloudflare";
        };
        service = "glances";
      };
    };
    services = {
      glances = {
        loadBalancer = {
          servers = [ { url = "http://${ip}:61208"; } ];
          passHostHeader = true;
        };
      };
    };
    middlewares = {
      securityHeaders = {
        headers = {
          customResponseHeaders = {
            X-Robots-Tag = "none,noarchive,nosnippet,notranslate,noimageindex";
            server = "";
            X-Forwarded-Proto = "https";
          };
          sslProxyHeaders = {
            X-Forwarded-Proto = "https";
          };
          referrerPolicy = "strict-origin-when-cross-origin";
          hostsProxyHeaders = [ "X-Forwarded-Host" ];
          customRequestHeaders = {
            X-Forwarded-Proto = "https";
          };
          contentTypeNosniff = true;
          browserXssFilter = true;
          forceSTSHeader = true;
          stsIncludeSubdomains = true;
          stsSeconds = 63072000;
          stsPreload = true;
        };
      };
      https-redirect = {
        redirectScheme = {
          scheme = "https";
        };
      };
      auth = {
        forwardauth = {
          address = "http://authentik-server:9000/outpost.goauthentik.io/auth/traefik";
          trustForwardHeader = true;
          authResponseHeaders = [
            "X-authentik-username"
            "X-authentik-groups"
            "X-authentik-email"
            "X-authentik-name"
            "X-authentik-uid"
            "X-authentik-jwt"
            "X-authentik-meta-jwks"
            "X-authentik-meta-outposts"
            "X-authentik-meta-provider"
            "X-authentik-meta-app"
            "X-authentik-meta-version"
          ];
        };
      };
    };
  };
}
