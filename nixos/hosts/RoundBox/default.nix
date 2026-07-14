{ ... }:

{
	imports = [
		./hardware-configuration.nix
		../../modules/profiles/desktop
	];

	# Electron Wayland support for Hermes Desktop
	environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
