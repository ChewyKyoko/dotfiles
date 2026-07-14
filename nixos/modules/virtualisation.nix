{ config, pkgs, lib, ... }:

{
	options.virtualisation.enable = lib.mkEnableOption "virtualisation support (virt-manager, docker)";

	config = lib.mkIf config.virtualisation.enable {
		virtualisation.libvirtd = {
			enable = true;
			onBoot = "ignore";
			onShutdown = "shutdown";
			extraConfig = ''
				unix_sock_group = "libvirtd"
			'';
			qemu = {
				swtpm.enable = true;
				vhostUserPackages = with pkgs; [ virtiofsd ];
			};
		};
		virtualisation.spiceUSBRedirection.enable = true;
		virtualisation.docker.enable = true;

		programs.virt-manager.enable = true;

		users.users.kyoko.extraGroups = [ "libvirtd" "kvm" "docker" ];

		environment.systemPackages = with pkgs; [
			dnsmasq
			virt-manager
		];

		systemd.services.libvirt-network-default = {
			description = "Start libvirt default network";
			after = [ "libvirtd.service" ];
			requires = [ "libvirtd.service" ];
			wantedBy = [ "multi-user.target" ];
			serviceConfig = {
				Type = "oneshot";
				RemainAfterExit = true;
				ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.libvirt}/bin/virsh -c qemu:///system net-start default || true'";
				ExecStop = "${pkgs.bash}/bin/bash -c '${pkgs.libvirt}/bin/virsh -c qemu:///system net-destroy default || true'";
			};
		};
	};
}
