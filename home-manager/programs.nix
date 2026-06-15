{ pkgs, ... }:
{
  programs = {
    # Bat configuration
    bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [
        batdiff
        batgrep
        batman
        batwatch
        prettybat
      ];
    };
  };
}
