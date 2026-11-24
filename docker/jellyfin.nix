{ ... }:
{
  virtualisation.oci-containers.containers = {
    # Jellyfin
    jellyfin = {
      image = "jellyfin/jellyfin:12";

      volumes = [
        "/etc/jellyfin-config:/config"
        "/tmp/jellyfin-cache:/cache"
        "/home/radeox/Storage/Media/:/media:ro"
      ];

      extraOptions = [
        "--network=host"
        "--device=/dev/dri/card0:/dev/dri/card0"
        "--device=/dev/dri/renderD128:/dev/dri/renderD128"
      ];

      autoStart = true;
    };
  };

  # Open port 8096 for Jellyfin
  networking.firewall.allowedTCPPorts = [ 8096 ];

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
        /run/current-system/sw/bin/docker pull jellyfin/jellyfin:12
        systemctl restart docker-jellyfin.service

        /run/current-system/sw/bin/docker system prune -f
      '';
    };
  };
}
