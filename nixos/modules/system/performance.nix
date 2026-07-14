{ ... }:
{
	services.irqbalance.enable = true;

	services.fstrim = {
		enable = true;
		interval = "weekly";
	};

	boot.kernel.sysctl = {
		"vm.swappiness" = 10;
		"vm.dirty_ratio" = 10;
		"vm.dirty_background_ratio" = 5;
		"vm.vfs_cache_pressure" = 50;
		"vm.dirty_writeback_centisecs" = 1500;
		"vm.page-cluster" = 0;
		"kernel.sched_autogroup_enabled" = 1;
		"kernel.sched_child_runs_first" = 1;
		"kernel.sched_min_granularity_ns" = 4000000;
		"kernel.sched_wakeup_granularity_ns" = 3000000;
		"kernel.sched_migration_cost_ns" = 500000;
		"kernel.nmi_watchdog" = 0;
		"net.ipv4.tcp_fastopen" = 3;
		"net.core.netdev_max_backlog" = 16384;
		"net.ipv4.tcp_congestion_control" = "bbr";
	};
}
