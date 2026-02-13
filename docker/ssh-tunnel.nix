{ ... }:
{
  virtualisation.oci-containers.containers = {
    # SSH Tunnel
    ssh-tunnel = {
      image = "docker.io/jnovack/autossh:latest";

      environment = {
        SSH_REMOTE_USER = "radeox";
        SSH_REMOTE_HOST = "server.radeox.it";
        SSH_TUNNEL_PORT = "28022";
        SSH_TARGET_PORT = "22";

        # Check connection health
        AUTOSSH_GATETIME = "0";
        AUTOSSH_POLL = "60";
      };

      volumes = [
        "/home/radeox/.ssh/id_ed25519:/id_rsa:ro"
      ];

      extraOptions = [
        "--network=host"
      ];

      autoStart = true;
    };
  };
}
