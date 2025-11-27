{ ... }:
{
  virtualisation.oci-containers.containers = {
    # SSH Tunnel
    ssh-tunnel = {
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
        "28022:localhost:2222"
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
}
