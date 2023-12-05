{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    disko = { url = "github:nix-community/disko";
              inputs.nixpkgs.follows = "nixpkgs"; };
    impermanence.url = "github:nix-community/impermanence";
    flake-programs-sqlite = {
      url = "github:wamserma/flake-programs-sqlite";
      inputs.nixpkgs.follows = "nixpkgs";
    };
		compose2nix.url = "github:aksiksi/compose2nix";
		compose2nix.inputs.nixpkgs.follows = "nixpkgs";
  };
  
  outputs = { self, nixpkgs, nixpkgs-unstable, impermanence, disko, ... }@inputs: 
    let
      system = "x86_64-linux";
			specialArgs = {
				pkgs-unstable = import nixpkgs-unstable {
					inherit system;
					config.allowUnfree = true;
				};
				inherit system;
				inherit inputs;
			};
    in 
  {
    nixosConfigurations.server = nixpkgs.lib.nixosSystem {
      inherit system; 
      inherit specialArgs;
      modules = [
        # Overlays-module to patch Fish shell issue until Fish shell 3.6.2 or 3.7.0 is released
				({ config, pkgs, ... }: { nixpkgs.overlays = [
					(final: prev: {
						fish = prev.fish.overrideAttrs (o: {
							patches = (o.patches or [ ]) ++ [
								(pkgs.fetchpatch {
									name = "fix-zfs-completion.path";
									url = "https://github.com/fish-shell/fish-shell/commit/85504ca694ae099f023ae0febb363238d9c64e8d.patch";
									sha256 = "sha256-lA0M7E/Z0NjuvppC7GZA5rWdL7c+5l+3SF5yUe7nEz8=";
								})
							];
						});
					})
				]; })

        ./configuration.nix
        disko.nixosModules.disko
        impermanence.nixosModules.impermanence
        inputs.flake-programs-sqlite.nixosModules.programs-sqlite
      ];
    };
  };
}
