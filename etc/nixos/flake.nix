{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    flake-programs-sqlite = {
      url = "github:wamserma/flake-programs-sqlite";
      inputs.nixpkgs.follows = "nixpkgs";
    };
		compose2nix = {
      url = "github:aksiksi/compose2nix";
		  inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.server = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
			specialArgs = {
        inherit inputs;
			};

      modules = [
        ./hosts/server
        ./configuration.nix
        inputs.disko.nixosModules.disko
        inputs.impermanence.nixosModules.impermanence
        inputs.flake-programs-sqlite.nixosModules.programs-sqlite
      ];
    };
  };
}
