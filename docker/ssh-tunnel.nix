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
}
