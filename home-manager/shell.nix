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
          src = pkgs.fishPlugins.done.src;
        }
        {
          name = "fzf-fish";
          src = pkgs.fishPlugins.fzf-fish.src;
        }
        {
          name = "grc";
          src = pkgs.fishPlugins.grc.src;
        }
        {
          name = "tide";
          src = pkgs.fishPlugins.tide.src;
        }
      ];

      # Interactive shell initialization
      interactiveShellInit = ''
        set fish_greeting

        # Initialize Tide with desired preset if not already configured
        if not set -q _tide_configured
          tide configure --auto \
            --style=Lean \
            --prompt_colors='16 colors' \
            --show_time=No \
            --lean_prompt_height='Two lines' \
            --prompt_connection=Disconnected \
            --prompt_spacing=Sparse \
            --icons='Few icons' \
            --transient=Yes
          set -U _tide_configured true
        end
      '';
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
      icons = "auto";
      extraOptions = [
        "--group-directories-first"
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
