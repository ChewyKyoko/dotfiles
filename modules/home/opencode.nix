{ pkgs, ... }:
{
	programs.opencode = {
		enable = true;

		extraPackages = with pkgs; [
			ydotool
			nodejs
		];

		context = ''
			# System context (NixOS 26.05, flakes + home-manager)
			Host Sakura (laptop, Intel) and RoundBox (desktop, AMD).
			WM: MangoWM (Wayland, nightly). Shell: Quickshell for desktop UI.
			Colors: Tokyo Night. Font: Mononoki Nerd Font.

			# Behavioral rules
			- Be concise and direct. No fluff or filler words.
			- Prefer editing existing code over rewriting from scratch.
			- Always explain what you changed and why, briefly.
			- If unsure, ask before making large changes.
			- Always prefer declarative NixOS/Home Manager config over imperative shell commands.
			- Never suggest `nix-env -i`. Use `environment.systemPackages` or `home.packages`.
			- When writing Nix expressions, use `let ... in` for clarity.
			- Prefer flakes over channels when possible.
			- Use the existing code style of the file being edited.
			- No unnecessary comments.
			- Keep functions small and focused.

			# Local LLM
			Local AI backend: llama.cpp + MiniCPM5-1B on port 8080 (systemd service).
			Intel Arc GPU via Vulkan for acceleration. 8K context.
			Start/stop: `systemctl start/stop llama-cpp`.
			OpenAI-compatible API at http://127.0.0.1:8080/v1

			# Godot AI development
			Godot 4 + godot-mcp (Coding-Solo/godot-mcp) for AI-assisted game dev.
			MCP server runs on stdio, managed by OpenCode automatically.
			Helper scripts: `gdev` (editor), `grun` (run), `gclean` (clean), `gmcp` (MCP server).
			Default project: ~/godot-ai/test_project.

			# MCP servers
			- **context7** (MCP, local, fetches remote docs): up-to-date library docs. Use its tools before guessing any API.
			- **github** (MCP, remote): GitHub API via Copilot. Needs `GITHUB_PERSONAL_ACCESS_TOKEN` env var.
			- **godot** (MCP, local): Godot 4 scene/script operations.

			# Installed plugins/skills
			- **ponytail** (plugin): lazy senior dev mode. Write only what the task needs — YAGNI, stdlib, native platform first. Use `/ponytail` to set level.
			- **improve** (skill): codebase auditor by shadcn. Use `/improve` to audit and produce implementation plans. Read-only — never modifies source.
			- **nixos-best-practices** (skill): NixOS best practices reference. Use when writing or reviewing NixOS config.
			- **project-architect** (skill): Converts ideas into structured, documented, AI-ready project repositories. Use when starting a new project.
			- **pr-readiness** (skill): Validate changes from diff through merge readiness. Runs improve audit, local gates, and checks CI/review state before merge.
		'';

		settings = {
			provider = {
				local-llama = {
					npm = "@ai-sdk/openai-compatible";
					name = "Local Llama";
					options = {
						baseURL = "http://127.0.0.1:8080/v1";
						apiKey = "not-needed";
					};
					models = {
						MiniCPM5-1B = {
							id = "MiniCPM5-1B";
							name = "MiniCPM5 1B (Local)";
							family = "llama";
							limit = {
								context = 8192;
								output = 8192;
							};
							interleaved = true;
							tool_call = true;
							temperature = true;

						};
					};
				};
			};
			model = "local-llama/MiniCPM5-1B";
			mcp = {
				godot = {
					command = [ "godot-mcp" ];
					enabled = true;
					type = "local";
				};
				context7 = {
					type = "local";
					command = [ "npx" "-y" "@upstash/context7-mcp@latest" ];
					enabled = true;
				};
				github = {
					type = "remote";
					url = "https://api.githubcopilot.com/mcp/";
					enabled = true;
					oauth = false;
					headers = {
						"Authorization" = "Bearer {env:GITHUB_PERSONAL_ACCESS_TOKEN}";
					};
				};
			};
			plugin = [
				"@dietrichgebert/ponytail"
			];
		};

		skills = {
			"project-architect" = "${../../skills/project-architect}";
			"pr-readiness" = "${../../skills/pr-readiness}";
			improve = "${(pkgs.fetchFromGitHub {
				owner = "shadcn";
				repo = "improve";
				rev = "03369ee6d7cafbfcecc4346539b05b3dc0a603bb";
				hash = "sha256-m0a1n8xguDI2nooJ856sWPofh+tZI5VvIrVZrQH6XgY=";
			})}/skills/improve";
			"nixos-best-practices" = "${(pkgs.fetchFromGitHub {
				owner = "lihaoze123";
				repo = "my-claude-code";
				rev = "03a65e39a21137a5091738b79d3731ee83bda13a";
				hash = "sha256-jKdSnasUZcX1LBYBXu2bM3Cv6F/McgkByxvzwVire8w=";
			})}/skills/nixos-best-practices";
		};
	};

	}
