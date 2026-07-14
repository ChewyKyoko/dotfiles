{ pkgs, ... }:
# Intel GPU drivers: VA-API, Vulkan
{
	# ── Kernel drivers + firmware ──────────────────────────────
	hardware.enableAllFirmware = true;
	hardware.enableRedistributableFirmware = true;
	boot.kernelParams = [ "i915.enable_guc=3" ];

	# ── OpenGL / VA-API / Vulkan ──────────────────────────────
	hardware.graphics = {
		enable = true;
		extraPackages = with pkgs; [
			# VA-API hardware video acceleration
			intel-media-driver
			vpl-gpu-rt

			# OpenCL + Level Zero (compute)
			intel-compute-runtime
		];
	};

	environment.sessionVariables = {
		LIBVA_DRIVER_NAME = "iHD";
	};
}
