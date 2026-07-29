{ pkgs, ... }:
{
	programs.opencode = {
		enable = true;

		extraPackages = with pkgs; [
			ydotool
			llama-cpp-vulkan
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
			Default project: ~/godot-ai/test_project. Use `@godot` agent for game development.

			# MCP servers
			- **context7** (MCP, local, fetches remote docs): up-to-date library docs. Use its tools before guessing any API.
			- **github** (MCP, remote): GitHub API via Copilot. Needs `GITHUB_PERSONAL_ACCESS_TOKEN` env var.
			- **godot** (MCP, local): Godot 4 scene/script operations.

			# Installed plugins/skills
			- **ponytail** (plugin): lazy senior dev mode. Write only what the task needs — YAGNI, stdlib, native platform first. Use `/ponytail` to set level.
			- **improve** (skill): codebase auditor by shadcn. Use `/improve` to audit and produce implementation plans. Read-only — never modifies source.
			- **nixos-best-practices** (skill): NixOS best practices reference. Use when writing or reviewing NixOS config.
		'';

		agents = {
			nix = ''
				You are a NixOS and Home Manager specialist.
				- Write correct, idiomatic Nix expressions.
				- Always verify packages exist in nixpkgs before suggesting them.
				- Prefer Home Manager options over raw dotfiles.
				- When writing modules, follow the standard NixOS module pattern with `options` and `config`.
			'';
			godot = ''
				You are a Godot 4 and GDScript specialist with access to the godot-mcp server.

				Available tools (via the godot MCP server):
				- `open_godot` — Launch Godot editor with a project. Args: projectPath (required).
				- `run_project` — Run a Godot project in debug mode. Args: projectPath (required).
				- `stop_project` — Stop a running project.
				- `get_output` — Get debug output from the last run.
				- `get_godot_version` — Check the installed Godot version.
				- `get_project_info` — Get project metadata from project.godot.
				- `list_projects` — Find Godot projects in a directory.
				- `get_scene_tree` — Read the scene tree of a scene file. Args: scenePath (required).
				- `create_scene` — Create a new scene with a root node. Args: projectPath, scenePath, rootNodeType.
				- `add_node` — Add a node to an existing scene. Args: scenePath, nodeType, nodeName, parentPath.
				- `create_script` — Create a GDScript file. Args: scriptPath, content.
				- `edit_script` — Edit an existing GDScript file. Args: scriptPath, content.
				- `save_scene` — Save the current scene. Args: scenePath.
				- `load_texture` — Load a texture into a Sprite2D node. Args: scenePath, nodePath, texturePath.

				Default project: ~/godot-ai/test_project

				Use the MCP tools to inspect, edit, and test the project. Do NOT use shell commands for Godot operations — use the MCP tools.
				For manual editor access, the user runs `gdev` (open editor), `grun` (run project), `gclean` (clean cache).
			'';
		};

		commands = {
			capture-screen = ''
				---
				description: Capture a screenshot
				---

				Capture a screenshot of the current screen using grim. Save to ~/screenshots/ with a timestamp filename.
				Then describe what you see in the screenshot.
			'';
			start-llama = ''
				---
				description: Start the local LLM server
				---

				Start the llama.cpp systemd service with MiniCPM5-1B for AI-assisted coding.
				Runs `systemctl start llama-cpp` to launch llama-server on port 8080.
				Uses Intel Arc GPU via Vulkan for acceleration.
				Context: 8K tokens, optimized for code completion and chat.
			'';
			stop-llama = ''
				---
				description: Stop the local LLM server
				---

				Stop the llama.cpp server gracefully.
				Runs `systemctl stop llama-cpp`.
			'';
			gdev = ''
				---
				description: Open Godot editor
				---

				Open the Godot editor with the default project.
				Runs `gdev` which calls `godot -e --path <project>`.
				The project path defaults to ~/godot-ai/test_project.
			'';
			grun = ''
				---
				description: Run Godot project
				---

				Run the Godot project in debug mode.
				Runs `grun` which calls `godot --path <project>`.
			'';
			gclean = ''
				---
				description: Clean Godot cache
				---

				Remove .godot/ and .import/ directories from the project.
				Runs `gclean`.
			'';
		};

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
							request.body.chat_template_kwargs = {
								enable_thinking = true;
							};
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
				"github:obra/superpowers"
			];
		};

		skills = {
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
