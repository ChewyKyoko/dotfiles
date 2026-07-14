{ ... }:
{
	services.power-profiles-daemon.enable = false;

	services.logind.settings = {
		Login.HandleLidSwitch = "suspend";
		Login.HandleLidSwitchExternalPower = "lock";
		Login.HandleLidSwitchDocked = "ignore";
	};

	services.udev.extraRules = ''
		ACTION=="add", SUBSYSTEM=="usb", ATTR{power/control}="on"
	'';
}
