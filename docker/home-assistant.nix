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

    # SSH Tunnel for Home Assistant
    homeassistant-tunnel = {
      image = "docker.io/jnovack/autossh:latest";

      environment = {
        SSH_REMOTE_USER = "radeox";
        SSH_REMOTE_HOST = "server.radeox.it";
        SSH_TUNNEL_PORT = "28123";
        SSH_TARGET_PORT = "8123";
      };

      volumes = [
        "/home/radeox/.ssh/id_rsa:/id_rsa:ro"
      ];

      extraOptions = [
        "--network=host"
      ];

      autoStart = true;
    };
  };

  # Periodically update HomeAssistant
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

        /run/current-system/sw/bin/docker system prune -f
      '';
    };
  };
}
