{ ... }:
{
  system.autoUpgrade = {
    enable = true;
    operation = "boot";
    flake = "/etc/nixos";
    flags = [
      "--update-input"
      "nixpkgs"
      "--commit-lock-file"
    ];
    dates = "weekly";
  };
}
