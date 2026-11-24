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
          background:
            radial-gradient(ellipse 80% 50% at 50% 0%, rgba(249, 115, 22, 0.16), transparent 65%),
            radial-gradient(circle at 80% 100%, rgba(234, 88, 12, 0.08), transparent 50%),
            linear-gradient(180deg, #12141a 0%, #090a0e 55%, #040406 100%);
          font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
          padding: 2rem;
          color: #f3f5f8;
        }
        .grid {
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(175px, 1fr));
          gap: 1.25rem;
          width: 100%;
          max-width: 780px;
        }
        a {
          position: relative;
          aspect-ratio: 1 / 1;
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          gap: 0.45rem;
          text-align: center;
          padding: 1.5rem;
          border-radius: 20px;
          background: linear-gradient(145deg, rgba(255, 255, 255, 0.065), rgba(255, 255, 255, 0.02));
          backdrop-filter: blur(16px);
          -webkit-backdrop-filter: blur(16px);
          border: 1px solid rgba(255, 255, 255, 0.09);
          box-shadow:
            0 10px 30px rgba(0, 0, 0, 0.45),
            inset 0 1px 0 rgba(255, 255, 255, 0.09);
          color: #f3f5f8;
          text-decoration: none;
          font-size: 1.2rem;
          font-weight: 600;
          letter-spacing: -0.015em;
          transition: transform 0.2s ease, border-color 0.2s ease, box-shadow 0.2s ease, background 0.2s ease;
        }
        a::before {
          content: "";
          width: 28px;
          height: 3px;
          border-radius: 999px;
          background: rgba(249, 115, 22, 0.45);
          margin-bottom: 0.35rem;
          transition: width 0.2s ease, background 0.2s ease, box-shadow 0.2s ease;
        }
        a span {
          font-size: 0.82rem;
          font-weight: 400;
          color: #8f98a8;
          letter-spacing: 0.01em;
          transition: color 0.2s ease;
        }
        a:hover {
          transform: translateY(-4px);
          background: linear-gradient(145deg, rgba(249, 115, 22, 0.12), rgba(255, 255, 255, 0.03));
          border-color: rgba(249, 115, 22, 0.55);
          box-shadow:
            0 16px 36px rgba(0, 0, 0, 0.6),
            0 0 28px rgba(249, 115, 22, 0.16),
            inset 0 1px 0 rgba(251, 146, 60, 0.3);
        }
        a:hover::before {
          width: 42px;
          background: #f97316;
          box-shadow: 0 0 12px rgba(249, 115, 22, 0.7);
        }
        a:hover span {
          color: #fdba74;
        }
        a:active {
          transform: translateY(-1px);
        }
      </style>
    </head>
    <body>
      <main class="grid">
        <a href="http://${netbirdIp}:8096">Jellyfin<span>Media server</span></a>
        <a href="http://${netbirdIp}:5055">Seerr<span>Requests</span></a>
        <a href="http://${netbirdIp}:8989">Sonarr<span>TV series</span></a>
        <a href="http://${netbirdIp}:7878">Radarr<span>Movies</span></a>
        <a href="http://${netbirdIp}:9696">Prowlarr<span>Indexers</span></a>
        <a href="http://${netbirdIp}:6767">Bazarr<span>Subtitles</span></a>
        <a href="http://${netbirdIp}:8080">qBittorrent<span>Downloads</span></a>
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
        Preferences.WebUI = {
          Username = "admin";
          Password_PBKDF2 = ''"@ByteArray(rQsaq2Y9tOnG0EW2/EQHUQ==:BEpyYGVvMv95ciMQugBbJhvxw5oNbbAFVg8ZX9I1RJ2HCb/IPytB4m3Yp1e0l7wIGiBoqhODaePEktejaXsRJA==)"'';
          AuthSubnetWhitelistEnabled = true;
          AuthSubnetWhitelist = "100.105.0.0/16"; # Bypass auth for NetBird peers
        };
        BitTorrent.Session = {
          DefaultSavePath = "/home/radeox/Storage/Downloads";
          GlobalMaxRatio = 2; # Stop at 2.0 ratio
          GlobalMaxSeedingMinutes = 10080; # Or after 7 days of seeding
          GlobalMaxInactiveSeedingMinutes = 2880; # Or after 48 hours of inactivity
          ShareLimitAction = "Stop"; # Stop torrent when limit is reached (Sonarr/Radarr handle removal after import)
        };
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
