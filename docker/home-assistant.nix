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
    ssh-tunnel-homeassistant = {
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
        "28123:localhost:8123"
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
