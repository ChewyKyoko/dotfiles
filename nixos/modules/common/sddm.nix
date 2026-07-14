{ pkgs, ... }:
# SDDM with enfield theme
let
	enfield-sddm = pkgs.stdenvNoCC.mkDerivation {
		name = "enfield-sddm";
		src = ../../assets/enfield;
		dontBuild = true;
		installPhase = ''
			mkdir -p $out/share/sddm/themes/enfield
			cp $src/bg.mp4 $out/share/sddm/themes/enfield/
			cp $src/Main.qml $out/share/sddm/themes/enfield/
			cp $src/BackgroundVideo.qml $out/share/sddm/themes/enfield/
			cp $src/theme.conf $out/share/sddm/themes/enfield/
			cp $src/metadata.desktop $out/share/sddm/themes/enfield/
			cp -r $src/font $out/share/sddm/themes/enfield/
		'';
	};
in
{
	services.displayManager.sddm = {
		enable = true;
		wayland.enable = true;
		theme = "enfield";
		package = pkgs.kdePackages.sddm;
		extraPackages = [
			enfield-sddm
			pkgs.kdePackages.qt5compat
			pkgs.kdePackages.qtmultimedia
			pkgs.kdePackages.qtsvg
			pkgs.kdePackages.qtvirtualkeyboard
		];
	};

	environment.systemPackages = [
		enfield-sddm
		pkgs.kdePackages.qtsvg
		pkgs.kdePackages.qtvirtualkeyboard
	];
}
