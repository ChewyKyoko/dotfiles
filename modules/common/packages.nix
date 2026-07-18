{ pkgs, ... }:
# System-wide packages and utilities
{
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
