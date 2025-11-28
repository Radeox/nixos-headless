{ ... }:
{
  virtualisation.oci-containers.containers = {
    # Syncthing
    syncthing = {
      image = "docker.io/syncthing/syncthing:latest";

      volumes = [
        "/etc/syncthing-data:/var/syncthing"
        "/etc/localtime:/etc/localtime:ro"
      ];

      environment = {
        TZ = "Europe/Rome";
        PUID = "1000";
        PGID = "1000";
      };

      ports = [
        "8384:8384" # Web UI
        "22000:22000/tcp" # TCP file transfers
        "22000:22000/udp" # QUIC file transfers
        "21027:21027/udp" # Receive local discovery broadcasts
      ];

      autoStart = true;
    };

    # SSH Tunnel for Syncthing
    ssh-tunnel-syncthing = {
      image = "docker.io/kroniak/ssh-client:latest";

      cmd = [
        "ssh"
        "-N"
        "-o"
        "StrictHostKeyChecking=no"
        "-o"
        "ServerAliveInterval=60"
        "-o"
        "ServerAliveCountMax=3"
        "-R"
        "28384:localhost:8384"
        "radeox@radeox.it"
      ];

      volumes = [
        "/root/.ssh:/root/.ssh:ro"
      ];

      extraOptions = [
        "--network=host"
      ];

      autoStart = true;
    };
  };

  # Periodically update Syncthing
  systemd = {
    timers.syncthing-update = {
      wantedBy = [ "timers.target" ];
      partOf = [ "syncthing-update.service" ];
      timerConfig = {
        OnCalendar = "*-*-* 04:00:00";
        Persistent = true;
      };
    };

    services.syncthing-update = {
      serviceConfig.Type = "oneshot";
      script = ''
        /run/current-system/sw/bin/docker pull docker.io/syncthing/syncthing:latest
        systemctl restart docker-syncthing.service

        /run/current-system/sw/bin/docker system prune -f
      '';
    };
  };
}
