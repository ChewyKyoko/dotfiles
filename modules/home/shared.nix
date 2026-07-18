{ pkgs, ... }:
# Home config shared by all hosts: shells, packages, godot scripts
{
	imports = [
		./nvf.nix
		./vesktop.nix
	];

	home.username = "kyoko";
	home.homeDirectory = "/home/kyoko";

	programs.home-manager.enable = true;
	programs.git = {
		enable = true;
		settings = {
			user.name = "Kyoko Sagawara";
			user.email = "154745885+ChewyKyoko@users.noreply.github.com";
			init.defaultBranch = "main";
			push.autoSetupRemote = true;
		};
	};

	programs.bash = {
		enable = true;
		shellAliases = {
			btw = "echo i use nixos, btw";
		};
		initExtra = ''
			eval "$(starship init bash)"
		'';
	};

	programs.starship = {
		enable = true;
		settings = {
			format = "$directory$character";
			directory = {
				format = "[$path]($style) ";
				style = "blue";
				truncation_length = 0;
				home_symbol = "";
			};
			character = {
				success_symbol = "[>](white)";
				error_symbol = "[>](red)";
			};
		};
	};

	programs.foot = {
		enable = true;
		settings = {
			main = {
				pad = "5x5 center";
				"initial-window-mode" = "maximized";
			};
			security = {
				osc52 = "enabled";
			};
			scrollback = {
				lines = 2000;
				multiplier = 2.0;
				"indicator-format" = "line";
			};
			cursor = {
				"unfocused-style" = "hollow";
				blink = "yes";
			};
			mouse = {
				"hide-when-typing" = true;
			};
			"key-bindings" = {
				"search-start" = "Control+Shift+f";
			};
		};
	};

	stylix = {
		enable = true;
		base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyodark.yaml";
		image = ../../assets/wallpaper.jpg;
		polarity = "dark";
		targets.starship.enable = true;
	};

	gtk = {
		enable = true;
		iconTheme = {
			name = "Papirus-Dark";
			package = pkgs.papirus-icon-theme;
		};
	};

	home.packages = with pkgs; [
		prismlauncher
		heroic
		pavucontrol
		mangohud
		gamemode
		mpv
		vesktop
		grim
		slurp
		satty
		wget
		playerctl
		brightnessctl
		papirus-icon-theme
		wl-clipboard
		ffmpeg
		nautilus
		nodejs
		gh
		python3
		uv
		llama-cpp-vulkan
		godot_4
		godot-mcp
		msnap
		libnotify        # notify-send (msnap dep)
		wayfreeze        # screen freeze before capture (msnap dep)
		gpu-screen-recorder  # screencast recording (msnap dep)

		# gdev — open project in Godot editor
		(writeScriptBin "gdev" ''
			#!${pkgs.dash}/bin/dash
			PROJECT="''${1:-~/godot-ai/test_project}"
			exec godot -e --path "$PROJECT"
		'')
		# grun — run project in debug mode
		(writeScriptBin "grun" ''
			#!${pkgs.dash}/bin/dash
			PROJECT="''${1:-~/godot-ai/test_project}"
			exec godot --path "$PROJECT"
		'')
		# gmcp — start the godot-mcp server (stdio transport)
		(writeScriptBin "gmcp" ''
			#!${pkgs.dash}/bin/dash
			exec godot-mcp
		'')
		# gclean — remove Godot cache artifacts
		(writeScriptBin "gclean" ''
			#!${pkgs.dash}/bin/dash
			PROJECT="''${1:-~/godot-ai/test_project}"
			echo "Cleaning $PROJECT..."
			rm -rf "$PROJECT/.godot" "$PROJECT/.import" 2>/dev/null
			echo "Done."
		'')
	];

	home.stateVersion = "26.05";
}
