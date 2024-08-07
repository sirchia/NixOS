{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
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
    
#      pkgs-bootstrap = import inputs.nixpkgs { inherit system; };
#
#			# create patched nixpkgs
#			nixpkgs-patched = pkgs-bootstrap.applyPatches {
#				name = "nixpkgs-patched";
#				src = inputs.nixpkgs;
#				patches = [ 
#          (pkgs-bootstrap.fetchpatch {
#                  name = "fix-oci-container-stop";
#                  url = "https://github.com/NixOS/nixpkgs/pull/248315.patch";
#                  sha256 = "sha256-MloB4h0nlyba88SAgdEVT9Ypxe31Hjo02oRnHtHIYZU=";
#          })
#       ];
#			};
#
#			# configure pkgs
#			pkgs = import nixpkgs-patched {
#				inherit system;
#				config = { allowUnfree = true;
#									 allowUnfreePredicate = (_: true); 
#                   packageOverrides = pkgs: {
#                     vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
#                   };
#        };
#			};
#
#      nixpkgs = (import "${nixpkgs-patched}/flake.nix").outputs { self = inputs.self; };

			# configure lib
			# lib = nixpkgs.lib;
    in 
  {
    nixosConfigurations.server = nixpkgs.lib.nixosSystem {
      inherit system; 
      inherit specialArgs;
#      inherit pkgs; # Inherit the patched pkgs

      modules = [
        ./hosts/server
        ./configuration.nix
        disko.nixosModules.disko
        impermanence.nixosModules.impermanence
        inputs.flake-programs-sqlite.nixosModules.programs-sqlite
      ];
    };
  };
}
