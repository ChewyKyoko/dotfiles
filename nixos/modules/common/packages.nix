{ pkgs, ... }:
# System-wide packages: file manager, utilities
{
	programs.thunar.enable = true;
	programs.thunar.plugins = with pkgs; [
		thunar
		thunar-volman
		thunar-archive-plugin
		thunar-media-tags-plugin
	];

	services.tumbler.enable = true;

	environment.systemPackages = with pkgs; [
		tree
		gparted
		file-roller
		playerctl
		blueman
		pwvucontrol
		playwright-mcp
	];

	}
