{ pkgs, ... }:
{
  programs = {
    # Fish shell configuration
    fish = {
      enable = true;

      # Fish plugins
      plugins = [
        {
          name = "done";
          src = pkgs.fishPlugins.done;
        }
        {
          name = "fzf-fish";
          src = pkgs.fishPlugins.fzf-fish;
        }
        {
          name = "grc";
          src = pkgs.fishPlugins.grc;
        }
      ];

      # Disable greeting
      interactiveShellInit = ''
        set fish_greeting
      '';
    };

    # Starship configuration
    starship = {
      enable = true;
      enableFishIntegration = true;
    };

    # Zoxide configuration
    zoxide = {
      enable = true;
      enableFishIntegration = true;
      options = [
        "--cmd cd"
      ];
    };

    # Eza configuration
    eza = {
      enable = true;
      enableFishIntegration = true;
      extraOptions = [
        "--group-directories-first"
        "--icons"
      ];
    };

    # Pay Respects configuration
    pay-respects = {
      enable = true;
      options = [
        "--alias"
        "f"
      ];
      enableFishIntegration = true;
    };
  };
}
