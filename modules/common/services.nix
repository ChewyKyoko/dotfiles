{ pkgs, lib, ... }:
# System services: PipeWire, llama-cpp, fwupd, libinput
{
	services = {
		upower.enable = true;
		# fstrim is configured in modules/system/performance.nix
		gvfs.enable = true;
		gnome.gnome-keyring.enable = true;
		pipewire = {
			enable = true;
			alsa.enable = true;
			alsa.support32Bit = true;
			pulse.enable = true;
			extraConfig.pipewire."92-low-latency" = {
				"context.properties" = {
					"default.clock.rate" = 48000;
					"default.clock.quantum" = 512;
					"default.clock.min-quantum" = 256;
					"default.clock.max-quantum" = 2048;
				};
			};
		};
		fwupd.enable = true;
		libinput.enable = true;

		llama-cpp = {
			enable = true;
			package = pkgs.llama-cpp-vulkan;
		};
	};

	# llm-cpp Vulkan shader cache workaround (nixpkgs#441531)
	systemd.services.llama-cpp.environment = {
		XDG_CACHE_HOME = "/var/cache/llama-cpp";
		MESA_SHADER_CACHE_DIR = "/var/cache/llama-cpp";
	};

	environment.systemPackages = [ pkgs.llama-cpp-vulkan ];

	# Don't auto-start — start manually with `systemctl start llama-cpp`
	systemd.services.llama-cpp.wantedBy = lib.mkForce [ ];
}
