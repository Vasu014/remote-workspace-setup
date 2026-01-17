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
      wsConfig = import ./config.nix;

      # Support both x86_64 and ARM
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];

      mkSystem = system: nixpkgs.lib.nixosSystem {
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
    in
    {
      # Default configuration (auto-detects architecture)
      nixosConfigurations.dev-workspace = mkSystem "x86_64-linux";

      # Explicit architecture configurations
      nixosConfigurations.dev-workspace-x86 = mkSystem "x86_64-linux";
      nixosConfigurations.dev-workspace-arm = mkSystem "aarch64-linux";
    };
}
