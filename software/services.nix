{ pkgs, ... }:
{
  services = {
    # Enable Samba shares and other stuff
    gvfs.enable = true;
    dbus.enable = true;
    tumbler.enable = true;

    # Thermald
    thermald.enable = true;

    # Power profiles
    power-profiles-daemon.enable = true;

    # Enable firmware updates
    fwupd.enable = true;

    # Enable network discovery
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
