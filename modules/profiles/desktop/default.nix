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

	zramSwap.memoryPercent = 25;

	boot.kernel.sysctl = {
		"kernel.sched_latency_ns" = 1000000;
	};
}
