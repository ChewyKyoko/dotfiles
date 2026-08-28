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
			host = "127.0.0.1";
			port = 8080;
		};
	};

	systemd.services.llama-cpp.environment = {
		XDG_CACHE_HOME = "/var/cache/llama-cpp";
		MESA_SHADER_CACHE_DIR = "/var/cache/llama-cpp";
	};

	environment.systemPackages = [
		pkgs.llama-cpp-vulkan
		(pkgs.writeShellScriptBin "llama-check" ''
			set -e
			echo "== llama-cpp status =="
			systemctl is-active llama-cpp && echo "active: yes" || echo "active: no"
			systemctl show -p ExecStart llama-cpp 2>/dev/null | tr ' ' '\n' | grep -q "\.gguf" \
				&& systemctl show -p ExecStart llama-cpp | sed -n 's/.*-m \([^ ]*\).*/model: \1/p' \
				|| echo "warn: no model configured — set services.llama-cpp.model = \"/path/to/MiniCPM5-1B.gguf\" (see https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md#get-health)"
			echo "== health (GET /health → {\"status\":\"ok\"} when ready, 503 when loading) =="
			if ${pkgs.curl}/bin/curl -sf http://127.0.0.1:8080/health 2>/dev/null | ${pkgs.jq}/bin/jq -e '.status == "ok"' >/dev/null 2>&1; then
				echo "health: ok"
			else
				echo "health: not ready — start: systemctl start llama-cpp; logs: journalctl -u llama-cpp -f"
				${pkgs.curl}/bin/curl -sf http://127.0.0.1:8080/health 2>&1 | head -c 200 || true
				echo ""
			fi
			echo "== models =="
			${pkgs.curl}/bin/curl -sf http://127.0.0.1:8080/v1/models 2>&1 | ${pkgs.jq}/bin/jq . 2>/dev/null | head -n 20 || echo "no /v1/models yet"
			echo "== quick test =="
			echo "curl -s http://127.0.0.1:8080/v1/chat/completions -H 'Content-Type: application/json' -d '{\"messages\":[{\"role\":\"user\",\"content\":\"hi\"}]}' | jq ."
		'')
	];

	systemd.services.llama-cpp.wantedBy = lib.mkForce [ ];
}
