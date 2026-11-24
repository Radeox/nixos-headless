{ lib, pkgs, ... }:
let
  netbirdIp = "100.105.30.102";

  cinemaPortal = pkgs.writeTextDir "index.html" ''
    <!DOCTYPE html>
    <html lang="it">
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <title>Cinema</title>
      <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
          min-height: 100vh;
          display: flex;
          align-items: center;
          justify-content: center;
          background: #0f1115;
          font-family: system-ui, -apple-system, sans-serif;
          padding: 1.5rem;
        }
        .grid {
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
          gap: 1rem;
          width: 100%;
          max-width: 560px;
        }
        a {
          display: flex;
          align-items: center;
          justify-content: center;
          padding: 1.15rem 1.25rem;
          border-radius: 12px;
          background: #1a1e26;
          border: 1px solid #2b313e;
          color: #eef1f6;
          text-decoration: none;
          font-size: 1.05rem;
          font-weight: 600;
          transition: background 0.15s ease, border-color 0.15s ease, transform 0.1s ease;
        }
        a:hover {
          background: #252b36;
          border-color: #4f8cff;
          transform: translateY(-2px);
        }
      </style>
    </head>
    <body>
      <main class="grid">
        <a href="http://${netbirdIp}:8096">Jellyfin</a>
        <a href="http://${netbirdIp}:5055">Seerr</a>
        <a href="http://${netbirdIp}:8989">Sonarr</a>
        <a href="http://${netbirdIp}:7878">Radarr</a>
        <a href="http://${netbirdIp}:9696">Prowlarr</a>
        <a href="http://${netbirdIp}:6767">Bazarr</a>
        <a href="http://${netbirdIp}:8080">qBittorrent</a>
      </main>
    </body>
    </html>
  '';
in
{
  # Shared group for Jellyfin and the *arr stack (read/write & hardlinks)
  users.groups.media.gid = 990;
  users.users.radeox.extraGroups = [ "media" ];

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
        "--group-add=990"
        "--device=/dev/dri/card0:/dev/dri/card0"
        "--device=/dev/dri/renderD128:/dev/dri/renderD128"
      ];

      autoStart = true;
    };
  };

  # Native NixOS *arr stack & headless BitTorrent client
  services = {
    # TV Shows manager (port 8989)
    sonarr = {
      enable = true;
      group = "media";
      openFirewall = false;
    };

    # Movies manager (port 7878)
    radarr = {
      enable = true;
      group = "media";
      openFirewall = false;
    };

    # Indexer manager (port 9696)
    prowlarr = {
      enable = true;
      openFirewall = false;
    };

    # Subtitles manager (port 6767)
    bazarr = {
      enable = true;
      group = "media";
      settings.general.port = 6767;
      openFirewall = false;
    };

    # Media request manager (port 5055)
    seerr = {
      enable = true;
      port = 5055;
      openFirewall = false;
    };

    # Flare solverr
    flaresolverr = {
      enable = true;
      port = 8191;
      openFirewall = false;
    };

    # Headless BitTorrent client with WebUI (port 8080)
    qbittorrent = {
      enable = true;
      group = "media";
      webuiPort = 8080;
      torrentingPort = 6881;
      openFirewall = false;
      serverConfig = {
        LegalNotice.Accepted = true;
        BitTorrent.Session.DefaultSavePath = "/home/radeox/Storage/Downloads";
      };
    };

    # Reverse proxy / static portal for cinema.radeox.it (HTTP only)
    nginx = {
      enable = true;
      virtualHosts."cinema.radeox.it" = {
        default = true;
        root = cinemaPortal;
        locations."/" = {
          index = "index.html";
        };
      };
    };
  };

  # Firewall rules:
  # - Jellyfin (8096) & BitTorrent peers (6881) open globally (LAN + NetBird)
  # - Portal (80) & *arr / qBittorrent WebUIs exposed exclusively on NetBird (nb-wt0)
  networking.firewall = {
    allowedTCPPorts = [
      8096
      6881
    ];
    allowedUDPPorts = [
      6881
    ];
    interfaces."nb-wt0".allowedTCPPorts = [
      80 # Cinema portal (cinema.radeox.it)
      5055 # Seerr
      6767 # Bazarr
      7878 # Radarr
      8080 # qBittorrent WebUI
      8989 # Sonarr
      9696 # Prowlarr
    ];
  };

  # Shared directories, Jellyfin updater, and *arr sandboxing/UMask
  systemd =
    let
      mediaServiceConfig = {
        UMask = lib.mkForce "0002";
        # Keep /home isolated while exposing only /home/radeox/Storage read-write
        ProtectHome = lib.mkForce "tmpfs";
        BindPaths = [ "/home/radeox/Storage" ];
      };
    in
    {
      # Ensure shared directories exist on the same filesystem with setgid + group write
      tmpfiles.rules = [
        "d /home/radeox/Storage/Media 2775 radeox media -"
        "d /home/radeox/Storage/Downloads 2775 radeox media -"
      ];

      timers.jellyfin-update = {
        wantedBy = [ "timers.target" ];
        partOf = [ "jellyfin-update.service" ];
        timerConfig = {
          OnCalendar = "*-*-* 04:00:00";
          Persistent = true;
        };
      };

      services = {
        jellyfin-update = {
          serviceConfig.Type = "oneshot";
          script = ''
            /run/current-system/sw/bin/docker pull jellyfin/jellyfin:12
            systemctl restart docker-jellyfin.service

            /run/current-system/sw/bin/docker system prune -f
          '';
        };

        sonarr.serviceConfig = mediaServiceConfig;
        radarr.serviceConfig = mediaServiceConfig;
        bazarr.serviceConfig = mediaServiceConfig;
        qbittorrent.serviceConfig = mediaServiceConfig;
      };
    };
}
