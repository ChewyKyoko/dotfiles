{ pkgs, ... }:
{
	services.displayManager = {
		defaultSession = "mango-uwsm";

		sddm = {
			enable = true;
			wayland.enable = true;
			theme = "enfield";
			package = pkgs.kdePackages.sddm;
			extraPackages = [
				pkgs.enfield
				pkgs.kdePackages.qt5compat
				pkgs.kdePackages.qtmultimedia
				pkgs.kdePackages.qtsvg
				pkgs.kdePackages.qtvirtualkeyboard
			];
		};
	};

	environment.systemPackages = [
		pkgs.enfield
		pkgs.kdePackages.qtsvg
		pkgs.kdePackages.qtvirtualkeyboard
	];
}
