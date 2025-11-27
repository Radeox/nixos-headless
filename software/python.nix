{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    python314
    ruff
    uv
    uv-sort
  ];
}
