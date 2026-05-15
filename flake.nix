{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

  inputs.home-manager = {
    url = "github:nix-community/home-manager/release-25.11";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.plasma-manager.url = "github:nix-community/plasma-manager";

  outputs = { nixpkgs, home-manager, plasma-manager, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        plasma-manager.homeModules.plasma-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.erwin = import ./home.nix;
        }
      ];
    };
  };
}
