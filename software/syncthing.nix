{ ... }:
{
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "radeox";
    configDir = "/home/radeox/.config/syncthing";
  };
}
