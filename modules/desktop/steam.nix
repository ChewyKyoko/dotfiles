{ config, lib, ... }:
{
	options.desktop.steam.enable = lib.mkEnableOption "Steam support";

	config = lib.mkIf config.desktop.steam.enable {
		programs.steam = {
			enable = true;
			remotePlay.openFirewall = true;
			dedicatedServer.openFirewall = true;
		};
	};
}
