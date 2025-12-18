{ ... }:
{
  virtualisation.oci-containers.containers = {
    # Jellyfin
    jellyfin = {
      image = "jellyfin/jellyfin:10";

      volumes = [
        "/etc/jellyfin-config:/config"
        "/tmp/jellyfin-cache:/cache"
        "/home/radeox/Storage/Media/:/media:ro"
      ];

      extraOptions = [
        "--network=host"
      ];

      autoStart = true;
    };

    # SSH Tunnel for Jellyfin
    jellyfin-tunnel = {
      image = "docker.io/jnovack/autossh:latest";

      environment = {
        SSH_REMOTE_USER = "radeox";
        SSH_REMOTE_HOST = "server.radeox.it";
        SSH_TUNNEL_PORT = "28096";
        SSH_TARGET_PORT = "8096";
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

  # Periodically update Jellyfin
  systemd = {
    timers.jellyfin-update = {
      wantedBy = [ "timers.target" ];
      partOf = [ "jellyfin-update.service" ];
      timerConfig = {
        OnCalendar = "*-*-* 04:00:00";
        Persistent = true;
      };
    };

    services.jellyfin-update = {
      serviceConfig.Type = "oneshot";
      script = ''
        /run/current-system/sw/bin/docker pull jellyfin/jellyfin:10
        systemctl restart docker-jellyfin.service

        /run/current-system/sw/bin/docker system prune -f
      '';
    };
  };
}
