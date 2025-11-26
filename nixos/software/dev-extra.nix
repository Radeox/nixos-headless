{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    ansible
    cargo
    cmake
    gcc
    git
    git-extras
    github-copilot-cli
    gnumake
    tree-sitter
  ];
}
