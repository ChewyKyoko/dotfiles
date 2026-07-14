{ ... }:

{
	imports = [
		../../common/base.nix
		../../common/network.nix
		../../common/services.nix
		../../common/desktop.nix
		../../common/packages.nix
		../../common/sddm.nix
		../../virtualisation.nix
		../../system/performance.nix
		../../hardware/gpu/amd.nix
		../../desktop/steam.nix
	];

	networking.hostName = "RoundBox";

	virtualisation.enable = false;
	desktop.steam.enable = true;
	programs.mango.enable = true;

	programs.gamemode.enable = true;
	programs.gamemode.settings.general.inhibit_screensaver = 0;

	programs.gamescope.enable = true;
	programs.gamescope.capSysNice = true;

	# Desktop-specific optimizations
	zramSwap = {
		enable = true;
		priority = 100;
		algorithm = "zstd";
		memoryPercent = 25;
	};

	# Gaming optimizations for desktop (unique to desktop)
	boot.kernel.sysctl = {
		"kernel.sched_latency_ns" = 1000000;
	};
}
