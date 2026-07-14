{ betterfox-nix, ... }:

{
	imports = [
		../../modules/home/shared.nix
		../../modules/home/quickshell
		../../modules/desktop/firefox/firefox.nix
		../../modules/home/mango.nix
		../../modules/home/opencode.nix
		betterfox-nix.modules.homeManager.betterfox
	];

	desktop.firefox.enable = true;
}
