# NixOS flake — Sakura (laptop) + RoundBox (desktop)
{
	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
		nvf = {
			url = "github:NotAShelf/nvf";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		mangowm = {
			url = "github:mangowm/mango";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		home-manager = {
			url = "github:nix-community/home-manager/release-26.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		stylix.url = "github:nix-community/stylix/release-26.05";
		quickshell = {
			url = "github:quickshell-mirror/quickshell/d99d87d5e5ec4e696815348692fdaaf0b6be1b2c";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		betterfox-nix = {
			url = "github:HeitorAugustoLN/betterfox-nix";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		msnap = {
			url = "github:xtheeq/msnap";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = inputs@{ self, nixpkgs, home-manager, stylix, mangowm, nvf, quickshell, betterfox-nix, msnap, ... }:
	let
		system = "x86_64-linux";

		pkgs = import nixpkgs {
			inherit system;
			config = {
				allowUnfree = true;
				# ponytail: allowAliases=true needed for wlroots attr
			};
			overlays = [
				# Provide xorg with non-deprecated attr aliases for upstream overlays
				(final: prev: {
					xorg = {
						inherit (prev) libxcb xcbutilwm;
					};
				})
				mangowm.overlays.default
				(import ./pkgs { inherit mangowm; })
				msnap.overlays.default
				# Build quickshell from source (pass libxcb directly, not via deprecated xorg attrset)
				(final: prev: {
					quickshell = final.callPackage (quickshell.outPath + "/default.nix") {
						xorg = {};
						libxcb = final.libxcb;
					};
				})
			];
		};

		mkHost = { hostName, user ? "kyoko" }: nixpkgs.lib.nixosSystem {
			inherit system;
			modules = [
				./hosts/${hostName}
				home-manager.nixosModules.home-manager
				mangowm.nixosModules.mango
				stylix.nixosModules.stylix
				{ nixpkgs.pkgs = pkgs; }
				{
					home-manager.useGlobalPkgs = true;
					home-manager.useUserPackages = true;
					home-manager.users.${user} = { imports = [
						(import ./hosts/${hostName}/home.nix)
						mangowm.hmModules.mango
					]; };
					home-manager.backupFileExtension = "backup";
					home-manager.extraSpecialArgs = { inherit nvf quickshell mangowm betterfox-nix msnap; };
				}
			];
		};
		mkHome = { hostName, user ? "kyoko" }: home-manager.lib.homeManagerConfiguration {
			inherit pkgs;
			modules = [
				stylix.homeModules.stylix
				(import ./hosts/${hostName}/home.nix)
				mangowm.hmModules.mango
			];
			extraSpecialArgs = { inherit nvf quickshell mangowm betterfox-nix msnap; };
		};
	in {
		nixosConfigurations = {
			RoundBox = mkHost { hostName = "RoundBox"; };
			Sakura = mkHost { hostName = "Sakura"; };
		};

		homeConfigurations = {
			"kyoko@RoundBox" = mkHome { hostName = "RoundBox"; };
			"kyoko@Sakura" = mkHome { hostName = "Sakura"; };
		};

		packages.${system} = {
			mangowc = pkgs.mangowc;
			mangowc-unwrapped = pkgs.mangowc-unwrapped;
		};
	};
}
