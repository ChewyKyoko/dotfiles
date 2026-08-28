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
		stylix = {
			url = "github:nix-community/stylix/release-26.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		quickshell = {
			url = "github:quickshell-mirror/quickshell/d99d87d5e5ec4e696815348692fdaaf0b6be1b2c";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		msnap = {
			url = "github:xtheeq/msnap";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		zen-browser = {
			url = "github:0xc000022070/zen-browser-flake";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		firefox-addons = {
			url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		# fresh llama.cpp for MiniCPM5 tokenizer support (stable 26.05 build is too old)
		llama-cpp = {
			url = "github:ggml-org/llama.cpp";
		};
	};

	outputs = inputs@{ self, nixpkgs, home-manager, stylix, mangowm, nvf, quickshell, msnap, zen-browser, firefox-addons, llama-cpp, ... }:
	let
		system = "x86_64-linux";

		pkgs = import nixpkgs {
			inherit system;
			config = {
				allowUnfree = true;
				# ponytail: allowAliases=true needed for wlroots attr
			};
			overlays = [
				(final: prev: {
					xorg = {
						inherit (prev) libxcb xcbutilwm;
					};
				})
				(final: prev: {
					# upstream llama.cpp flake, vulkan build — replaces the stale nixpkgs one
					llama-cpp-vulkan = llama-cpp.packages.${system}.vulkan;
				})
				(final: prev: {
					gpu-screen-recorder = prev.gpu-screen-recorder.overrideAttrs (old: {
						postFixup = (old.postFixup or "") + ''
							patchelf --add-rpath ${prev.libglvnd}/lib $out/bin/.wrapped/gpu-screen-recorder
						'';
					});
				})
				mangowm.overlays.default
				(import ./pkgs { inherit mangowm; })
				msnap.overlays.default
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
						(import ./hosts/Sakura/home.nix)
						mangowm.hmModules.mango
						zen-browser.homeModules.beta
					]; };
					home-manager.backupFileExtension = "backup";
					home-manager.extraSpecialArgs = { inherit nvf quickshell mangowm msnap firefox-addons; };
				}
			];
		};
		mkHome = { hostName, user ? "kyoko" }: home-manager.lib.homeManagerConfiguration {
			inherit pkgs;
			modules = [
				stylix.homeModules.stylix
				(import ./hosts/Sakura/home.nix)
				mangowm.hmModules.mango
				zen-browser.homeModules.beta
			];
			extraSpecialArgs = { inherit nvf quickshell mangowm msnap firefox-addons; };
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
			inherit (zen-browser.packages.${system}) default;
		};
	};
}
