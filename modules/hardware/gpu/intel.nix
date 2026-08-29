{ pkgs, ... }:
# Intel GPU drivers: VA-API, Vulkan
{
	hardware.enableAllFirmware = true;
	hardware.enableRedistributableFirmware = true;
	boot.kernelParams = [ "i915.enable_guc=3" ];

	hardware.graphics = {
		enable = true;
		extraPackages = with pkgs; [
			intel-media-driver
			vpl-gpu-rt
			intel-compute-runtime
		];
	};

	environment.sessionVariables = {
		LIBVA_DRIVER_NAME = "iHD";
	};
}
