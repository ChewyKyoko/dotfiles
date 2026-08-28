{ ... }:

{
	imports = [
		../../common/base.nix
		../../common/network.nix
		../../common/services.nix
		../../common/desktop.nix
		../../common/sddm.nix
		../../system/performance.nix
		../../hardware/gpu/amd.nix
	];

	networking.hostName = "RoundBox";

	# Desktop-specific optimizations
	zramSwap.memoryPercent = 25;

	# Gaming optimizations for desktop (unique to desktop)
	boot.kernel.sysctl = {
		"kernel.sched_latency_ns" = 1000000;
	};
}
