{
  description = "Radeox - NixOS";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Manage dotfiles
    home-manager.url = "github:nix-community/home-manager/release-25.11";

    # Secure boot
    lanzaboote.url = "github:nix-community/lanzaboote/v0.4.3";
  };

  outputs =
    { nixpkgs
    , home-manager
    , lanzaboote
    , ...
    }:
    {
      nixosConfigurations = {
        # ----- B-Dell configuration -----
        B-Dell = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          modules = [
            # Lanzaboote - Secure boot
            lanzaboote.nixosModules.lanzaboote

            # Setup Home Manager
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.radeox = {
                imports = [
                  ./home-manager
                ];
              };
            }

            # My NixOS configuration
            ./environment
            ./hardware
            ./software
            ./system

            # Docker containers
            ./docker

            # Host specific configuration
            ./hosts/b-dell.nix
          ];
        };
      };
    };
}
