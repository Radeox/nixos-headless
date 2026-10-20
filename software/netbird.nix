{ config, lib, ... }: {
  services.netbird = {
    clients.wt0 = {
      config = {
        ManagementURL = {
          Scheme = "https";
          Host = "netbird.radeox.it:443";
        };
        AdminURL = {
          Scheme = "https";
          Host = "netbird.radeox.it:443";
        };
      };

      login = {
        enable = true;
        setupKeyFile = "/home/radeox/Documents/Netbird/${lib.toLower config.networking.hostName}.key";
      };

      port = 51821;
      ui.enable = false;
      openFirewall = true;
      openInternalFirewall = true;
    };

    useRoutingFeatures = "both";
  };

  # Use netbird client-side DNS resolution
  services.resolved.enable = true;

  # Allow SSH exclusively on the NetBird private mesh interface
  networking.firewall.interfaces."nb-wt0".allowedTCPPorts = [ 22 ];
}
