{ pkgs, ... }:

{
  services.ollama = {
    enable = true;
    package = pkgs.ollama;

    # Listening ports
    host = "0.0.0.0";
    port = 11434;

    # Preload models
    loadModels = [
      "qwen3:4b"
    ];
  };

  # Open port 11434 for Ollama
  networking.firewall.allowedTCPPorts = [ 11434 ];

  # Cli package
  environment.systemPackages = [ pkgs.ollama ];
}
