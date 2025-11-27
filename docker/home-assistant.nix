{ ... }:
{
  virtualisation.oci-containers.containers = {
    # Home-assistant
    homeassistant = {
      image = "docker.io/homeassistant/home-assistant:latest";

      volumes = [
        "/etc/home-assistant-data:/config"
        "/etc/localtime:/etc/localtime:ro"
        "/run/dbus:/run/dbus:ro"
      ];

      environment.TZ = "Europe/Rome";
      extraOptions = [
        "--network=host"
        "--cap-add=NET_ADMIN"
        "--cap-add=NET_RAW"
      ];

      autoStart = true;
    };

    # DuckDNS
    duckdns = {
      image = "lscr.io/linuxserver/duckdns:latest";

      environmentFiles = [
        "/etc/duckdns/.env"
      ];

      extraOptions = [
        "--network=host"
      ];

      autoStart = true;
    };
  };

  # Lets encrypt
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;

    virtualHosts."sblumbo.duckdns.org" = {
      forceSSL = true;
      enableACME = true;

      extraConfig = ''
        proxy_buffering off;
      '';

      locations."/" = {
        proxyPass = "http://[::1]:8123";
        proxyWebsockets = true;
      };
    };
  };

  # ACME
  security.acme = {
    acceptTerms = true;
    defaults.email = "dawid.weglarz95@gmail.com";
  };

  # Periodically update HomeAssistant + DuckDNS
  systemd = {
    timers.home-assistant-update = {
      wantedBy = [ "timers.target" ];
      partOf = [ "home-assistant-update.service" ];
      timerConfig = {
        OnCalendar = "*-*-* 04:00:00";
        Persistent = true;
      };
    };

    services.home-assistant-update = {
      serviceConfig.Type = "oneshot";
      script = ''
        /run/current-system/sw/bin/docker pull docker.io/homeassistant/home-assistant:latest
        systemctl restart docker-homeassistant.service

        /run/current-system/sw/bin/docker pull lscr.io/linuxserver/duckdns:latest
        systemctl restart docker-duckdns.service

        /run/current-system/sw/bin/docker system prune -f
      '';
    };
  };
}
