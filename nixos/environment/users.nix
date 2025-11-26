{ pkgs, ... }:
{
  users = {
    # Users definition
    users.radeox = {
      isNormalUser = true;
      description = "Radeox";
      extraGroups = [
        "dialout"
        "docker"
        "kvm"
        "lp"
        "networkmanager"
        "scanner"
        "video"
        "wheel"
      ];
    };

    # Set Fish as default shell
    defaultUserShell = pkgs.fish;
  };
}
