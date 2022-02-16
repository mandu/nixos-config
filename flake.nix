{
  inputs = {
    home-manager.url = "github:nix-community/home-manager/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    #home-manager.url = "github:nix-community/home-manager/release-21.11";
    #nixpkgs.url = "github:NixOS/nixpkgs/release-21.11";
    # nixos-hardware = {
    #   url = "github:NixOS/nixos-hardware/master";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # emacs.url = "github:nix-community/emacs-overlay/master";
  };

  #outputs = { self, nixpkgs, home-manager, nixos-hardware, emacs, ... }: {
  outputs = { self, nixpkgs, home-manager, ... }: {

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
            home-manager.users.mandu = import ./modules/home.nix;
          }
        ];
      };
    };
  };
}
