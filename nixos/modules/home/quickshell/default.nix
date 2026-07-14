{ pkgs, ... }:
# Quickshell desktop panel (conky-style, Wayland-native)
{
	programs.quickshell = {
		enable = true;
		package = pkgs.quickshell;
		configs.quickshell = ./conf;
		activeConfig = "quickshell";
		systemd.enable = false;
	};
}
