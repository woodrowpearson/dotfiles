{
  description = "Woody's darwin configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, darwin }: {
    darwinConfigurations = {
      WoodyMBP = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./hosts/WoodyMBP
          home-manager.darwinModules.home-manager
        ];
      };
    };
  };
}
