{ pkgs, ... }:
# AMD GPU drivers: VA-API, Vulkan
{
	hardware.enableAllFirmware = true;
	hardware.graphics = {
		enable = true;
		extraPackages = with pkgs; [
			mesa
			libva
			libvdpau-va-gl
		];
	};

	environment.sessionVariables = {
		LIBVA_DRIVER_NAME = "radeonsi";
		VDPAU_DRIVER = "radeonsi";
	};
}
