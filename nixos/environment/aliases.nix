{ ... }:
{
  environment.shellAliases = {
    # NixOS commands
    nix-update = "sudo nix flake update --flake /etc/nixos && sudo nixos-rebuild switch --upgrade --accept-flake-config --flake /etc/nixos";
    nix-config = "cd /etc/nixos && vim";
    nix-clean = "sudo nix-store --gc && sudo nix-collect-garbage -d && sudo nixos-rebuild boot";

    # Aliases
    d = "lazydocker";
    dc = "docker compose";
    g = "lazygit";
    ll = "ls -l";
    p = "ps aux | grep ";
    r = "ranger";
    rgrep = "rg";
    sl = "ls";
    sudo = "sudo ";

    # Basic commands
    cat = "bat -p";
    df = "duf";
    du = "dust";
  };
}
