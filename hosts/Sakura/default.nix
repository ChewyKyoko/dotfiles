{ lib, ... }:

{
	imports = [
		./hardware-configuration.nix
		../../modules/profiles/laptop
	];

	# Laptop doesn't need virtualization (Docker, libvirt, etc.)
	virtualisation.enable = lib.mkForce false;

	# Electron/Wayland support (Hermes desktop, VS Code, etc.)
	environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
