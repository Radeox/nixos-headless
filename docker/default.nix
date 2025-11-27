{ ... }:
{
  imports = [
    ./home-assistant.nix
    ./jellyfin.nix
    ./ssh-tunnel.nix
  ];
}
