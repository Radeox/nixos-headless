{ ... }:
{
  imports = [
    ./auto-upgrade.nix
    ./dev-extra.nix
    ./extra.nix
    ./packages.nix
    ./python.nix
    ./networking.nix
    ./secureboot.nix
    ./services.nix
    ./system.nix
  ];
}
