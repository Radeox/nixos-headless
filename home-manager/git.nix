{ ... }:
{
  # Git configuration
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Dawid Weglarz";
        email = "dawid.weglarz95@gmail.com";
      };

      safe.directory = "/etc/nixos";
    };
  };

  # Lazygit configuration
  programs.lazygit = {
    enable = true;

    settings = {
      "notARepository" = "quit";
    };
  };
}
