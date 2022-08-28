{
  inputs = {
    home-manager.url = "github:nix-community/home-manager/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    #home-manager.url = "github:nix-community/home-manager/release-21.11";
    #nixpkgs.url = "github:NixOS/nixpkgs/release-21.11";
    # nixos-hardware = {
    #   url = "github:NixOS/nixos-hardware/master";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # emacs.url = "github:nix-community/emacs-overlay/master";
  };

  #outputs = { self, nixpkgs, home-manager, nixos-hardware, emacs, ... }: {
  outputs = { self, nixpkgs, home-manager, darwin, ... }: {

    nixosConfigurations = {
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
