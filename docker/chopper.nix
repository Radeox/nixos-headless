{ ... }:
{
  virtualisation.oci-containers.containers = {
    # Chopper - Markdown Spec Sharing Portal
    chopper = {
      image = "chopper:latest";
      pull = "never";

      volumes = [
        "/var/lib/chopper:/data/specs"
      ];

      environment = {
        PORT = "9000";
        BASE_URL = "http://chopper.radeox.it:9000";
        STORAGE_DIR = "/data/specs";
        SPEC_TTL_SECONDS = "604800";
      };

      extraOptions = [
        "--network=host"
      ];

      autoStart = true;
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/chopper 0755 root root -"
  ];

  # Open port 9000 on NetBird interface
  networking.firewall.interfaces."nb-wt0".allowedTCPPorts = [ 9000 ];
}
