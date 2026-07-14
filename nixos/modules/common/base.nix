{ pkgs, ... }:
# Base system config shared by all hosts
{
	boot = {
		kernelPackages = pkgs.linuxPackages_latest;
		initrd.systemd.enable = true;
		kernel.sysctl = {"vm.max_map_count" = 2147483642;};
		loader.systemd-boot.enable = true;
		loader.systemd-boot.configurationLimit = 10;
		loader.efi.canTouchEfiVariables = true;
	};

	time.timeZone = "America/Paramaribo";
	i18n = {
		defaultLocale = "en_US.UTF-8";
		extraLocaleSettings = {
			LC_TIME = "en_US.UTF-8";
			LC_MEASUREMENT = "en_US.UTF-8";
		};
	};

	users.users.kyoko = {
		isNormalUser = true;
		extraGroups = [ "wheel" ];
	};

	security.sudo = {
		enable = true;
		wheelNeedsPassword = true;
	};

	nix = {
		settings = {
			experimental-features = [ "nix-command" "flakes" ];
			auto-optimise-store = true;
			warn-dirty = false;
			min-free = 5000000000;      # auto-GC when <5GB free
			max-free = 10000000000;    # stop GC when 10GB freed
			max-jobs = "auto";
			keep-derivations = false;
			keep-outputs = false;
			compress-build-log = false;
		};
		extraOptions = ''
			builders-use-substitutes = true
		'';
	};
	documentation.enable = false;
	# allowUnfree is configured in the pkgs instance creation in flake.nix

	# Required for dconf settings (GTK apps, etc.). Without this,
	# GUI apps can hang on launch waiting for the dconf service.
	programs.dconf.enable = true;

	# GTK icon cache — speeds up icon lookups for all GTK apps.
	# Defaults to false on Wayland-only systems without xserver.
	gtk.iconCache.enable = true;

	environment.systemPackages = with pkgs; [
		hicolor-icon-theme
	];

	system.stateVersion = "26.05";

	# Journal to tmpfs — fewer disk writes, logs survive until reboot
	services.journald.extraConfig = ''
		Storage=volatile
		DefaultTimeoutStopSec=5s
	'';
}
