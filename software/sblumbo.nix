{ pkgs, ... }:
{
  systemd.services.sblumbo = {
    description = "Sblumbo - Obsidian ingest worker";

    serviceConfig = {
      Type = "oneshot";
      User = "radeox";
      WorkingDirectory = "/home/radeox/Sources/Radeox/sblumbo";
    };
    startAt = "*-*-* 23:30:00";

    script = ''
      ${pkgs.python3}/bin/python sblumbo.py
    '';
  };
}
