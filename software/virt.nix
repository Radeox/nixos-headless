{ pkgs, ... }:
{
  virtualisation = {
    # Docker config
    docker.enable = true;
    containers.enable = true;
    oci-containers.backend = "docker";
  };

  # Docker utils
  environment.systemPackages = with pkgs; [
    docker-compose
    lazydocker
  ];
}
