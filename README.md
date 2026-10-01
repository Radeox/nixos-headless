# Headless NixOS Configuration

Flake-based NixOS configuration for a headless home server (target host: `B-Dell`). Configured with Lanzaboote Secure Boot, TPM2-backed LUKS encryption, declarative OCI/Docker services, and integrated Home Manager.

---

## 📁 Repository Structure

The configuration is modularized into distinct layers:

- **[`flake.nix`](flake.nix)**: Flake entrypoint defining dependencies (`nixpkgs`, `home-manager`, `lanzaboote`) and system outputs (`nixosConfigurations.B-Dell`).
- **[`hosts/`](hosts/)**: Host-specific definitions, including partition layouts, LUKS/TPM2 cryptroot, secondary storage (`crypttab`), and machine-specific SSH/DHCP settings.
- **[`docker/`](docker/)**: Declarative OCI/Docker container definitions (e.g., Home Assistant, Jellyfin, and remote SSH tunnels).
- **[`system/`](system/)**: Core system settings, network management, bootloader, and Secure Boot (`lanzaboote`).
- **[`hardware/`](hardware/)**: Hardware-specific configurations such as Intel graphics acceleration and microcode updates.
- **[`software/`](software/)**: System-wide packages and systemd services (e.g., Syncthing, Avahi discovery, thermald, power management).
- **[`environment/`](environment/)**: System environment setup, custom helper scripts (`activate-venv`, `docker-clean`, `myip`), shell aliases, and user account definition.
- **[`home-manager/`](home-manager/)**: User environment managed via Home Manager (Fish shell, Git, Neovim, CLI utilities).

---

## 🌳 File Tree

```text
.
├── flake.nix                  # Flake entrypoint & system outputs
├── flake.lock                 # Pinned flake inputs
├── hosts/
│   └── b-dell.nix             # Host-specific hardware, mounts, LUKS & SSH
├── docker/
│   ├── default.nix            # Container imports aggregator
│   ├── home-assistant.nix     # Home Assistant container & tunnel
│   ├── jellyfin.nix           # Jellyfin media server container
│   └── ssh-tunnel.nix         # SSH reverse tunnel services
├── system/
│   ├── default.nix            # System configuration aggregator
│   ├── networking.nix         # Network settings & firewall config
│   ├── secureboot.nix         # Lanzaboote Secure Boot parameters
│   └── system.nix             # Nix daemon settings, stateVersion & GC
├── hardware/
│   ├── default.nix            # Hardware modules aggregator
│   ├── graphics.nix           # Hardware acceleration & GPU drivers
│   └── hardware.nix           # General hardware options
├── software/
│   ├── default.nix            # Software aggregator
│   ├── extra.nix              # Optional/extra tools
│   ├── packages.nix           # System-wide packages list
│   └── services.nix           # System services (Syncthing, Avahi, thermald)
├── environment/
│   ├── default.nix            # Environment modules aggregator
│   ├── aliases.nix            # Global shell aliases
│   ├── environment.nix        # Shell & session variables
│   ├── locale.nix             # Timezone and localization
│   ├── scripts.nix            # Custom shell scripts (activate-venv, docker-clean, myip)
│   └── users.nix              # User accounts and groups
└── home-manager/
    ├── default.nix            # Home Manager base config
    ├── git.nix                # Git & LazyGit configuration
    ├── neovim.nix             # Neovim editor setup
    ├── programs.nix           # User-specific CLI tools & terminal apps
    └── shell.nix              # Fish shell configuration & starship prompt
```
