{
  pkgs,
  config,
  lib,
  modulesPath,
  ...
}:
{
  # Hostname
  networking.hostName = "B-Dell";

  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];

    initrd = {
      # TPM2
      systemd = {
        enable = true;
        tpm2.enable = true;
      };

      # LUKS2
      luks.devices.cryptroot.device = "/dev/disk/by-uuid/c24c7c1c-87cf-453d-b4d1-8b78d0164d5d";

      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [ ];
    };
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/ECA2-CE6F";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/affbc5cc-f52b-4729-b411-b9fdeca9d001";
    fsType = "ext4";
  };

  fileSystems."/home/radeox/Storage" = {
    device = "/dev/disk/by-uuid/876c35ed-939a-4d89-9729-7a9878357ac6";
    fsType = "ext4";
    options = [
      "user"
      "nofail"
    ];
  };

  swapDevices = [ { device = "/dev/disk/by-uuid/a1cdc93e-c7f5-49eb-94ce-20168fb08297"; } ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Enables DHCP on each ethernet and wireless interface
  networking.useDHCP = lib.mkDefault true;

  # Enable TRIM for SSDs
  services.fstrim.enable = lib.mkDefault true;

  # SSH server
  services.openssh = {
    enable = true;
    ports = [ 2222 ];

    settings = {
      PasswordAuthentication = false;
      AllowUsers = [ "radeox" ];
      UseDns = true;
      X11Forwarding = false;
      PermitRootLogin = "no";
    };
  };

  # Turn off firewall
  networking.firewall.enable = lib.mkForce false;

  # Add secondary storage
  environment.etc.crypttab = {
    mode = "0600";
    text = ''
      cryptstorage UUID=f166bd0d-8887-40df-b237-35ba6bb7c6ee /root/storage.key
    '';
  };
}
