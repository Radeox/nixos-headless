{ pkgs, ... }:
{
  # Enable Secure Boot support
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  # Install sbctl for managing secure boot keys
  environment.systemPackages = with pkgs; [
    sbctl
    tpm2-tools
    tpm2-tss
  ];

  # Enable TPM2 support
  security.tpm2.enable = true;
}
