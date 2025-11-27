{ pkgs, ... }:
{
  hardware = {
    # Enable bluetooth
    bluetooth = {
      enable = true;
      powerOnBoot = true;

      # Show battery levels for more devices
      settings.General = {
        Experimental = true;
      };
    };
  };
}
