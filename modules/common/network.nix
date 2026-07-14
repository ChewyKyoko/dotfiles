{ lib, ... }:
# Networking: NetworkManager, firewall, MAC randomization
{
	networking = {
		networkmanager.enable = true;
		firewall = {
			enable = true;
			allowedTCPPorts = [
				22
				80
				443
				59010
				59011
				25565
				8080
			];
			allowedUDPPorts = [
				59010
				59011
			];
		};

		networkmanager.wifi = {
			powersave = true;
			scanRandMacAddress = true;
			macAddress = "random";  # per-connection
		};
	};

	# Don't wait for network at boot — Wi-Fi laptop, no remotely-mounted filesystems
	systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;

	# Prevent NetworkManager restart during nixos-rebuild — avoids WiFi drop
	systemd.services.NetworkManager.restartIfChanged = lib.mkForce false;
}
