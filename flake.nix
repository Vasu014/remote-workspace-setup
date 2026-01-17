{
  description = "Reproducible NixOS remote dev workspace";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      wsConfig = import ./config.nix;
    in
    {
      nixosConfigurations.dev-workspace = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit wsConfig; };
        modules = [
          ./hardware-configuration.nix
          ./modules/system.nix
          ./modules/services.nix
          ./modules/packages.nix
          ./modules/users.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit wsConfig; };
            home-manager.users.${wsConfig.username} = import ./home/user.nix;
          }
        ];
      };
    };
}
