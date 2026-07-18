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
		../../hardware/gpu/intel.nix
		../../hardware/thinkpad.nix
		../../desktop/steam.nix
	];

	networking.hostName = "Sakura";

	virtualisation.enable = false;
	desktop.steam.enable = true;
	programs.mango.enable = true;

	# GameMode system service (not just user package)
	programs.gamemode.enable = true;
	programs.gamemode.settings.general.inhibit_screensaver = 0;

	# Gamescope micro-compositor for gaming
	programs.gamescope.enable = true;
	programs.gamescope.capSysNice = true;

	zramSwap = {
		enable = true;
		priority = 100;
		algorithm = "zstd";
		memoryPercent = 30;   # Lower CPU overhead during gaming
	};

	powerManagement.enable = true;

	services.thermald.enable = true;

	# Systems with a dedicated GPU can optimise battery life with
	# hardware.nvidia.prime.offload.enable = true;
	# This is NOT enabled on Sakura (Intel iGPU only).

	# Meteor Lake power-saver kernel parameters
	# Reference: https://blog.fsck.com/agent-blog/2026/03/30/linux-power-tuning-meteor-lake/
	boot.kernelParams = [
		"nmi_watchdog=0"               # ~0.5W — disable hardware watchdog
		"i915.enable_psr=2"            # ~0.3W — Panel Self Refresh (idle display)
		"i915.enable_fbc=1"            # ~0.1W — framebuffer compression
		"i915.enable_dc=4"             # ~0.1W — deep display power states
		"iwlwifi.power_save=1"         # ~0.2W — Wi-Fi power save
		"snd_hda_intel.power_save=0"   # audio codec — disabled, was causing mic/audio glitches
		"acpi.ec_no_wakeup=1"          # ~0.1W — prevent EC spurious wakeups (ThinkPad)
		"usbcore.autosuspend=5"        # USB devices autosuspend after 5s idle

		# Clear Linux-style optimizations for latency/throughput balance
		"vm.page-cluster=0"            # Reduce NUMA pressure
		"kernel.nmi_watchdog=0"        # Disable NMI watchdog
		"kernel.sched_migration_cost_ns=500000" # Faster task migration
	];

	services.auto-cpufreq.enable = true;
	services.auto-cpufreq.settings = {
		battery = {
			governor = "powersave";           # intel_pstate only supports performance/powersave
			turbo = "auto";                   # Allow short bursts (saves total energy vs sustained low)
			energy_performance_preference = "balance_power";  # Intel HWP: balanced efficiency
			# Battery charge thresholds — prolong battery lifespan by capping at 80%
			enable_thresholds = true;
			start_threshold = 75;
			stop_threshold = 80;
		};
		charger = {
			governor = "performance";
			turbo = "auto";
			energy_performance_preference = "performance";    # Max performance when charging
		};
	};

	# Additional HWP tuning via sysfs (applied after auto-cpufreq)
	systemd.services.auto-cpufreq.postStart = ''
		for cpu in /sys/devices/system/cpu/cpu[0-9]*/cpufreq; do
			[ -f "$cpu/energy_performance_preference" ] && \
				echo "balance_power" > "$cpu/energy_performance_preference" 2>/dev/null || true
		done
	'';
}
