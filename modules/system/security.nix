{ lib, ... }:
# Kernel + system hardening (NixOS wiki: NixOS_Hardening)
# Baselines removed in 26.05 (profiles.hardened, linux_hardened) — hand-rolled subset.
# Trimmed for a smooth-running desktop: no oops=panic, no page_poison,
# io_uring left enabled (Proton/Steam), perf/ptrace usable for dev.
{
	# Prevents replacing the running kernel image (kexec) + hibernation.
	security.protectKernelImage = true;

	boot.kernelParams = [
		"slab_nomerge"
		"page_alloc.shuffle=1"
		"randomize_kstack_offset=on"
		"vsyscall=none"
	];

	# Obscure/rarely-audited attack surface.
	boot.blacklistedKernelModules = [
		# Obscure network protocols
		"ax25"
		"netrom"
		"rose"
		"dccp"
		"sctp"
		"rds"
		"tipc"
		"decnet"
		"econet"
		"ipx"
		"appletalk"
		# Old/rare filesystems
		"adfs"
		"affs"
		"bfs"
		"befs"
		"cramfs"
		"efs"
		"erofs"
		"exofs"
		"freevxfs"
		"minix"
		"nilfs2"
		"qnx4"
		"qnx6"
		"sysv"
		"ufs"
		"hfs"
		"hpfs"
	];

	# Hide kernel pointers even for CAP_SYSLOG
	boot.kernel.sysctl = {
		"kernel.kptr_restrict" = "2";
		# Lock down dmesg (boot addresses, module versions)
		"kernel.dmesg_restrict" = 1;
		"kernel.unprivileged_bpf_disabled" = 1;
		# Restrict ptrace to children (yama 1) — debuggers still work
		"kernel.yama.ptrace_scope" = 1;
		# Full ASLR
		"kernel.randomize_va_space" = 2;
		"vm.mmap_rnd_bits" = 32;
		"vm.mmap_rnd_compat_bits" = 16;
		# fs: don't overshoot in shared writable dirs
		"fs.protected_symlinks" = 1;
		"fs.protected_hardlinks" = 1;
		"fs.protected_fifos" = 2;
		"fs.protected_regular" = 2;
		# Disable unprivileged userfaultfd (LPE sink)
		"vm.unprivileged_userfaultfd" = 0;
		# TTY line discipline autoload (CAP_SYS_MODULE gate)
		"dev.tty.ldisc_autoload" = 0;

		# Strict reverse path filtering (IP spoofing)
		"net.ipv4.conf.all.rp_filter" = 1;
		"net.ipv4.conf.default.rp_filter" = 1;
		"net.ipv4.conf.all.accept_redirects" = 0;
		"net.ipv4.conf.default.accept_redirects" = 0;
		"net.ipv4.conf.all.secure_redirects" = 0;
		"net.ipv4.conf.default.secure_redirects" = 0;
		"net.ipv6.conf.all.accept_redirects" = 0;
		"net.ipv6.conf.default.accept_redirects" = 0;
		"net.ipv4.conf.all.send_redirects" = 0;
		"net.ipv4.conf.default.send_redirects" = 0;
		"net.ipv4.conf.all.accept_source_route" = 0;
		"net.ipv4.conf.default.accept_source_route" = 0;
		"net.ipv6.conf.all.accept_source_route" = 0;
		"net.ipv6.conf.default.accept_source_route" = 0;
		# Smurf / multicast ICMP defense
		"net.ipv4.icmp_echo_ignore_broadcasts" = 1;
		"net.ipv4.icmp_ignore_bogus_error_responses" = 1;
		# SYN flood protection
		"net.ipv4.tcp_syncookies" = 1;
		"net.ipv4.tcp_rfc1337" = 1;
	};

	# Only allow real users to use the Nix daemon socket
	# (trusted-users already defaults to root + @wheel)
	nix.settings.allowed-users = [ "@users" ];
}
