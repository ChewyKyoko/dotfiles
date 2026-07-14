{ pkgs, ... }:

let
	tokyoNightCSS = pkgs.fetchurl {
		url = "https://raw.githubusercontent.com/Dyzean/Tokyo-Night/main/themes/tokyo-night.theme.css";
		hash = "sha256-fHEAihqI0UlrM0KOdvUaBukgH+GA82fetqFHMOckVRk=";
	};
in {
	home.file.".config/vesktop/themes/tokyo-night.css" = {
		source = tokyoNightCSS;
		# ponytail: theme must be enabled in Vencord settings once (Themes > Local Themes)
	};
}
