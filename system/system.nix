{ pkgs, ... }:
{
  boot = {
    # Use 6.17 stock kernel
    kernelPackages = pkgs.linuxPackages_6_17;

    # NTFS support
    supportedFilesystems = [ "ntfs" ];
  };

  nix = {
    # Enable flakes
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Enable auto-optimisation of the store
    optimise.automatic = true;
    settings.auto-optimise-store = true;

    # Enable automatic garbage collection
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  system = {
    stateVersion = "24.05";

    # Pretty rebuild messages
    activationScripts.diff = {
      supportsDryActivation = true;
      text = ''
        ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
      '';
    };
  };
}
