{
  inputs = {
    home-manager.url = "github:nix-community/home-manager/master";
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    # The rc hub server: NixOS stable, not master (it upgrades itself nightly).
    nixpkgs-hub.url = "github:NixOS/nixpkgs/nixos-26.05";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs-hub";
    # rc's dev hosts: the hub's stable NixOS (fully in the binary cache) with
    # the matching home-manager release.
    home-manager-hub.url = "github:nix-community/home-manager/release-26.05";
    home-manager-hub.inputs.nixpkgs.follows = "nixpkgs-hub";

    #home-manager.url = "github:nix-community/home-manager/release-21.11";
    #nixpkgs.url = "github:NixOS/nixpkgs/release-21.11";
    # nixos-hardware = {
    #   url = "github:NixOS/nixos-hardware/master";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # emacs.url = "github:nix-community/emacs-overlay/master";
  };

  #outputs = { self, nixpkgs, home-manager, nixos-hardware, emacs, ... }: {
  outputs = { self, nixpkgs, home-manager, darwin, nixpkgs-hub, disko, home-manager-hub, ... }: {

    nixosConfigurations = {
      # Hetzner Cloud ARM VM; install: nixos-anywhere --flake .#hub (see
      # remote-code docs/hub.md).
      hub = nixpkgs-hub.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          disko.nixosModules.disko
          ./systems/hub-disk.nix
          ./systems/hub.nix
        ];
      };

      # rc's disposable dev hosts (Hetzner Cloud; `rc hosts up` installs them
      # with nixos-anywhere): one config, an output per CPU, the mbp's home
      # modules. NixOS stable like the hub, not master: master's packages
      # aren't all in the binary cache, and an install would compile them.
      dev-x86 = nixpkgs-hub.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          home-manager-hub.nixosModules.home-manager
          ./systems/dev-host.nix
        ];
      };
      dev-arm = nixpkgs-hub.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          disko.nixosModules.disko
          home-manager-hub.nixosModules.home-manager
          ./systems/dev-host.nix
        ];
      };

      parallels-vm = nixpkgs.lib.nixosSystem {
        # system = "x86_64-linux";
        system = "aarch64-linux";
        modules = [
          # nixos-hardware.nixosModules.lenovo-thinkpad-x230

          ./systems/parallels-vm.nix

          home-manager.nixosModules.home-manager
          {
            # nixpkgs.overlays = [ emacs.overlay ];

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.mandu = import ./modules/linux-home.nix;
          }
        ];
      };

      devbox = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./systems/devbox.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.mandu = import ./modules/linux-home.nix;
          }
        ];
      };

    };


    darwinConfigurations = {
      Mikkos-MacBook-Air = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        #modules = attrValues self.darwinModules ++ [
        modules = [
          ./systems/Mikkos-MacBook-Air.nix

          home-manager.darwinModules.home-manager
          {
            #nixpkgs = nixpkgsConfig;

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.mandu = import ./modules/darwin-home.nix;
          }
        ];
      };


      Mikkos-MacBook-Pro = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        #modules = attrValues self.darwinModules ++ [
        modules = [
          ./systems/Mikkos-MacBook-Pro.nix

          home-manager.darwinModules.home-manager
          {
            #nixpkgs = nixpkgsConfig;

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.mandu = import ./modules/darwin-home.nix;
          }
        ];
      };
    };

  };
}
