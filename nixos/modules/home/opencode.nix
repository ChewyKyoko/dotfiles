{ pkgs, ... }:
{
	programs.opencode = {
		enable = true;

		extraPackages = with pkgs; [
			ydotool
			llama-cpp-vulkan
			playwright-mcp
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
			Local AI backend: llama.cpp + Qwen3.5 2B Q4_K_M on port 8080 (systemd service).
			Intel Arc GPU via Vulkan for acceleration. 8K context.
			Start/stop: `systemctl start/stop llama-cpp`.
			OpenAI-compatible API at http://127.0.0.1:8080/v1

			# Godot AI development
			Godot 4 + godot-mcp (Coding-Solo/godot-mcp) for AI-assisted game dev.
			MCP server runs on stdio, managed by OpenCode automatically.
			Helper scripts: `gdev` (editor), `grun` (run), `gclean` (clean), `gmcp` (MCP server).
			Default project: ~/godot-ai/test_project. Use `@godot` agent for game development.

			# Installed plugins/skills
			- **ponytail** (plugin): lazy senior dev mode. Write only what the task needs — YAGNI, stdlib, native platform first. Use `/ponytail` to set level.
			- **improve** (skill): codebase auditor by shadcn. Use `/improve` to audit and produce implementation plans. Read-only — never modifies source.
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

				Start the llama.cpp systemd service with Qwen3.5 2B for AI-assisted coding.
				Runs `systemctl start llama-cpp` to launch llama-server on port 8080.
				Uses Intel Arc GPU via Vulkan for acceleration.
				Context: 8K tokens, optimized for code completion and chat.
			'';
			stop-llama = ''
				---
				description: Stop the local LLM server
				---

				Stop the llama.cpp server gracefully.
				Runs `~/ai/bin/stop-llama.sh`.
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

		# ponytail: HM's programs.opencode can't express provider/model+mcp via settings,
		# so those are in a direct file at ~/.config/opencode/opencode.json
		# keeping skills here for now as HM supports it
		skills = {
			improve = "${(pkgs.fetchFromGitHub {
				owner = "shadcn";
				repo = "improve";
				rev = "03369ee6d7cafbfcecc4346539b05b3dc0a603bb";
				hash = "sha256-m0a1n8xguDI2nooJ856sWPofh+tZI5VvIrVZrQH6XgY=";
			})}/skills/improve";
		};
	};

	}
