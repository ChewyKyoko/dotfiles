{ config, pkgs, lib, ... }:
# Desktop environment: UWSM, mango, gpu-screen-recorder, Qt, Bluetooth
let
	# Wrap UWSM with the mango environment preloader plugin
	uwsmWithPlugin = pkgs.symlinkJoin {
		name = "uwsm-with-mango-plugin-${pkgs.uwsm.version}";
		paths = [ pkgs.uwsm ];
		postBuild = ''
			ln -sf ${pkgs.mangowc.passthru.uwsm-plugin} $out/share/uwsm/plugins/mango.sh
		'';
		meta = pkgs.uwsm.meta // { outputsToInstall = [ "out" ]; };
	};

	enfield-lock = pkgs.stdenvNoCC.mkDerivation {
		name = "enfield-lock";
		src = ../../assets/enfield;
		nativeBuildInputs = [ pkgs.makeWrapper ];
		dontBuild = true;
		installPhase = ''
			mkdir -p $out/share/enfield-lock
			cp $src/lock_shell.qml $out/share/enfield-lock/
			ln -sf ${pkgs.enfield}/share/enfield/shim $out/share/enfield-lock/shim
			ln -sf ${pkgs.enfield}/share/enfield/imports $out/share/enfield-lock/imports
			mkdir -p $out/share/enfield-lock/themes/enfield
			ln -sf ${pkgs.enfield}/share/enfield/bg.mp4 $out/share/enfield-lock/themes/enfield/bg.mp4
			ln -sf ${pkgs.enfield}/share/enfield/Main.qml $out/share/enfield-lock/themes/enfield/Main.qml
			ln -sf ${pkgs.enfield}/share/enfield/BackgroundVideo.qml $out/share/enfield-lock/themes/enfield/BackgroundVideo.qml
			ln -sf ${pkgs.enfield}/share/enfield/theme.conf $out/share/enfield-lock/themes/enfield/theme.conf
			ln -sf ${pkgs.enfield}/share/enfield/metadata.desktop $out/share/enfield-lock/themes/enfield/metadata.desktop

			makeWrapper ${pkgs.quickshell}/bin/quickshell $out/bin/qylock-lock \
				--add-flags "-p $out/share/enfield-lock/lock_shell.qml" \
				--set QML2_IMPORT_PATH "$out/share/enfield-lock/imports" \
				--set QML_XHR_ALLOW_FILE_READ "1" \
				--set QS_THEME "enfield" \
				--set QS_THEME_PATH "$out/share/enfield-lock/themes/enfield"
		'';
	};
in
{
	imports = [ ../desktop/steam.nix ];

	programs.uwsm = {
		enable = true;
		package = uwsmWithPlugin;
		waylandCompositors = {
			mango = {
				prettyName = "Mango";
				comment = "Mango Wayland Compositor managed by UWSM";
				binPath = "/run/current-system/sw/bin/mango";
			};
		};
	};

	# Tell the upstream mango module not to create a plain SDDM entry
	# (UWSM generates "Mango (UWSM)" — we only want that one)
	programs.mango.enable = true;
	programs.mango.addLoginEntry = false;

	# GameMode system service (not just user package)
	programs.gamemode.enable = true;
	programs.gamemode.settings.general.inhibit_screensaver = 0;

	# Gamescope micro-compositor for gaming
	programs.gamescope.enable = true;
	programs.gamescope.capSysNice = true;

	desktop.steam.enable = true;

	programs.xwayland.enable = true;

	xdg.portal = {
		enable = true;
		wlr.enable = true;
		configPackages = [ pkgs.mangowc ];
		extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
		config.mango = lib.mkForce {
			default = [ "gtk" ];
			"org.freedesktop.impl.portal.ScreenCast" = "wlr";
			"org.freedesktop.impl.portal.Screenshot" = "wlr";
			"org.freedesktop.impl.portal.Inhibit" = "none";
		};
	};

	programs.nh = {
		enable = true;
		flake = "/etc/nixos";
	};

	stylix = {
		enable = true;
		base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyodark.yaml";
		image = ../../assets/wallpaper.jpg;
		polarity = "dark";
		opacity.terminal = 0.8;
		cursor.package = pkgs.bibata-cursors;
		cursor.name = "Bibata-Modern-Ice";
		cursor.size = 24;
		fonts = {
			monospace = {
				package = pkgs.nerd-fonts.mononoki;
				name = "Mononoki Nerd Font";
			};
			sansSerif = {
				package = pkgs.inter;
				name = "Inter";
			};
			sizes = {
				applications = 14;
				desktop = 12;
				popups = 12;
				terminal = 14;
			};
		};

		targets = {
			gtk.enable = true;
			qt.enable = true;
		};
	};

	security.polkit.enable = true;
	security.rtkit.enable = true;

	# gpu-screen-recorder — GPU-based screencast (used by msnap)
	programs.gpu-screen-recorder.enable = true;

	# Module only wraps gsr-kms-server — main binary also needs cap_sys_nice
	security.wrappers."gpu-screen-recorder" = {
		owner = "root";
		group = "root";
		capabilities = "cap_sys_nice+ep";
		source = "${pkgs.gpu-screen-recorder}/bin/.wrapped/gpu-screen-recorder";
	};

	# ── Lock screen (enfield lock) ───────────────────────────
	environment.systemPackages = [
		enfield-lock
		pkgs.kdePackages.qtmultimedia
		pkgs.kdePackages.qt5compat
	];

	fonts.packages = with pkgs; [
		noto-fonts
		noto-fonts-cjk-sans
		noto-fonts-color-emoji
		material-symbols
	];

	# ── Qt platform theming ────────────────────────────────────
	# stylix.targets.qt sets platformTheme = "qt5ct" automatically
	qt.enable = true;
	qt.style = lib.mkDefault "adwaita-dark";

	hardware.bluetooth = {
		enable = true;
		powerOnBoot = false;
		settings = {
			General = {
				Experimental = true;
				FastConnectable = true;
			};
			Policy = {
				AutoEnable = true;
			};
		};
	};
}
