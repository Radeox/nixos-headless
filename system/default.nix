{ ... }:
{
  imports = [
    ./auto-upgrade.nix
    ./networking.nix
    ./secureboot.nix
    ./system.nix
  ];
}
