{ config, lib, ... }:
# MangoWM keybinds, rules, theme — per-user
let
	c = hex: "0x${hex}ff";
	col = config.lib.stylix.colors;

	launch = {
		terminal   = "SUPER,Return,spawn,footclient";
		bluetooth  = "SUPER,b,spawn,blueman-manager";
		wifi       = "SUPER,w,spawn,iwgtk";
		audio      = "SUPER,v,spawn,pwvucontrol";
		files      = "SUPER,e,spawn,nautilus";
	};

	quickshell = {
		launcher  = "SUPER,r,spawn,quickshell --config quickshell ipc call appLauncher toggle";
		clipboard = "SUPER+SHIFT,v,spawn,quickshell --config quickshell ipc call clipMenu toggle";
		emoji     = "SUPER,period,spawn,quickshell --config quickshell ipc call emojiMenu toggle";
		wallpaper = "SUPER+SHIFT,w,spawn,quickshell --config quickshell ipc call wallpaperSelector toggle";
	};

	media = {
		volup     = "none,XF86AudioRaiseVolume,spawn,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
		voldown   = "none,XF86AudioLowerVolume,spawn,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
		mute      = "none,XF86AudioMute,spawn,wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
		micmute   = "none,XF86AudioMicMute,spawn,wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
		togglemic = "SUPER,a,spawn,wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
		brightup  = "none,XF86MonBrightnessUp,spawn,brightnessctl set 5%+";
		brightdown = "none,XF86MonBrightnessDown,spawn,brightnessctl set 5%-";
	};

	nav = {
		reload    = "SUPER+SHIFT,r,reload_config";
		kill      = "SUPER+SHIFT,c,killclient,";
		fullscreen = "SUPER,f,togglefullscreen,";
		minimized = "SUPER,minus,minimized,";
		quit      = "SUPER,Escape,spawn,uwsm stop";
		lock      = "SUPER+SHIFT,Escape,spawn,qylock-lock";
		zoom      = "ALT,s,zoom,";
		focuslast = "SUPER,u,focuslast";
		focusstack = "SUPER,Tab,focusstack,next";
		switch_layout = "SUPER,n,switch_layout";
		togglefloat = "SUPER,space,togglefloating,";
	};

	vim_focus = {
		left  = "SUPER,h,focusdir,left";
		down  = "SUPER,j,focusdir,down";
		up    = "SUPER,k,focusdir,up";
		right = "SUPER,l,focusdir,right";
	};

	vim_move = {
		left  = "SUPER+SHIFT,h,exchange_client,left";
		down  = "SUPER+SHIFT,j,exchange_client,down";
		up    = "SUPER+SHIFT,k,exchange_client,up";
		right = "SUPER+SHIFT,l,exchange_client,right";
	};

	alt_focus = {
		left  = "ALT,Left,focusdir,left";
		down  = "ALT,Down,focusdir,down";
		up    = "ALT,Up,focusdir,up";
		right = "ALT,Right,focusdir,right";
	};

	alt_move = {
		left  = "SUPER+SHIFT,Left,exchange_client,left";
		down  = "SUPER+SHIFT,Down,exchange_client,down";
		up    = "SUPER+SHIFT,Up,exchange_client,up";
		right = "SUPER+SHIFT,Right,exchange_client,right";
	};

	tag_view = map (n: "Super,${toString n},view,${toString n},0") (lib.range 1 6);
	tag_move = map (n: "Alt,${toString n},tag,${toString n},0") (lib.range 1 6);
	tag_toggle_view = map (n: "Super,${toString n},toggleview,${toString n}") (lib.range 1 6);
	tag_toggle_tag = map (n: "ctrl+Super,${toString n},toggletag,${toString n}") (lib.range 1 6);

	layout = {
		set_tile     = "CTRL+SUPER,i,setlayout,tile";
		set_scroller = "CTRL+SUPER,l,setlayout,scroller";
		incmaster    = "SUPER,equal,incnmaster,1";
		decmaster    = "SUPER,minus,incnmaster,-1";
	};

	view = {
		left = "SUPER,Left,viewtoleft,0";
		left_with_client = "CTRL,Left,viewtoleft_have_client,0";
		right = "SUPER,Right,viewtoright,0";
		right_with_client = "CTRL,Right,viewtoright_have_client,0";
		tag_left  = "CTRL+SUPER,Left,tagtoleft,0";
		tag_right = "CTRL+SUPER,Right,tagtoright,0";
	};

	axis = [
		"SUPER,UP,viewtoleft_have_client"
		"SUPER,DOWN,viewtoright_have_client"
		"alt,UP,focusdir,left"
		"alt,DOWN,focusdir,right"
		"shift+super,UP,exchange_client,left"
		"shift+super,DOWN,exchange_client,right"
	];

	gestures = [
		"none,left,3,focusdir,left"
		"none,right,3,focusdir,right"
		"none,up,3,focusdir,up"
		"none,down,3,focusdir,down"
		"none,left,4,viewtoleft_have_client"
		"none,right,4,viewtoright_have_client"
		"none,up,4,toggleoverview,1"
		"none,down,4,toggleoverview,1"
	];

	msnap = {
		gui    = "none,Print,spawn,msnap gui";
		region = "SHIFT,Print,spawn_shell,msnap shot --region";
		cast   = "ALT,Print,spawn_shell,msnap cast --toggle --region";
	};

	mouse = [
		"SUPER,btn_left,moveresize,move"
		"SUPER,btn_right,moveresize,curresize"
		"SUPER+CTRL,btn_left,minimized"
		"SUPER+CTRL,btn_right,killclient"
	];
in {
	services.cliphist.enable = true;

	wayland.windowManager.mango = {
		enable = true;

		settings = {
			syncobj_enable = 1;
			xwayland_persistence = 1;
			no_border_when_single = 0;
			smartgaps = 0;
			drag_tile_to_tile = 1;
			cursor_size = 24;

			border_radius = 13;
			no_radius_when_single = 0;
			borderpx = 2;
			rootcolor = c col.base00-hex;
			bordercolor = c col.base02-hex;
			focuscolor = c col.base0D-hex;
			maximizescreencolor = c col.base0D-hex;
			urgentcolor = c col.base08-hex;
			scratchpadcolor = c col.base03-hex;
			globalcolor = c col.base02-hex;
			overlaycolor = c col.base04-hex;
			focused_opacity = 1.0;
			unfocused_opacity = 1.0;

			blur = 1;
			blur_optimized = 1;
			blur_params_radius = 5;
			blur_params_num_passes = 2;

			animations = 1;
			layer_animations = 1;
			animation_type_open = "slide";
			animation_type_close = "slide";
			animation_fade_in = 1;
			animation_fade_out = 1;
			tag_animation_direction = 1;
			zoom_initial_ratio = 0.4;
			zoom_end_ratio = 0.8;
			fadein_begin_opacity = 0.5;
			fadeout_begin_opacity = 0.8;
			animation_duration_move = 250;
			animation_duration_open = 200;
			animation_duration_tag = 200;
			animation_duration_close = 300;
			animation_duration_focus = 0;
			animation_curve_open = "0.46,1.0,0.29,1";
			animation_curve_move = "0.46,1.0,0.29,1";
			animation_curve_tag = "0.46,1.0,0.29,1";
			animation_curve_close = "0.08,0.92,0,1";
			animation_curve_focus = "0.46,1.0,0.29,1";
			animation_curve_opafadeout = "0.5,0.5,0.5,0.5";
			animation_curve_opafadein = "0.46,1.0,0.29,1";

			new_is_master = 1;
			default_mfact = 0.55;
			default_nmaster = 1;
			gappih = 5;
			gappiv = 5;
			gappoh = 5;
			gappov = 5;

			scroller_structs = 20;
			scroller_default_proportion = 0.8;
			scroller_focus_center = 0;
			scroller_prefer_center = 0;
			edge_scroller_pointer_focus = 1;
			scroller_default_proportion_single = 1.0;
			scroller_proportion_preset = [ "0.5" "0.8" "1.0" ];

			hotarea_size = 10;
			enable_hotarea = 1;
			ov_tab_mode = 0;
			overviewgappi = 5;
			overviewgappo = 30;

			focus_on_activate = 1;
			sloppyfocus = 1;
			warpcursor = 1;
			focus_cross_monitor = 0;
			focus_cross_tag = 0;

			enable_floating_snap = 1;
			snap_distance = 30;
			scratchpad_width_ratio = 0.8;
			scratchpad_height_ratio = 0.9;

			repeat_rate = 25;
			repeat_delay = 600;
			numlockon = 0;
			xkb_rules_layout = "us";
			axis_bind_apply_timeout = 100;

			disable_trackpad = 0;
			tap_to_click = 1;
			tap_and_drag = 1;
			drag_lock = 1;
			trackpad_natural_scrolling = 0;
			disable_while_typing = 1;
			left_handed = 0;
			middle_button_emulation = 0;
			swipe_min_threshold = 1;

			mouse_natural_scrolling = 0;

			windowrule = [
				"isfloating:1,width:0.8,height:0.8,appid:org.gnome.Nautilus"
				"isfloating:1,width:0.8,height:0.8,appid:pwvucontrol"
				"isfloating:1,width:0.8,height:0.8,appid:blueman-manager"
				"isfloating:1,width:0.8,height:0.8,appid:nm-connection-editor"
				"isfloating:1,width:0.8,height:0.8,appid:xdg-desktop-portal"
				"isfloating:1,title:Picture-in-Picture"
				"isfloating:1,title:Save As..."
				"isfloating:1,title:Open File..."
				"isfloating:1,title:Library"
				"isfloating:1,title:Properties"
				"isfloating:1,title:Preferences"
				"isfloating:1,appid:mpv"
			];

			tagrule = map (n: "id:${toString n},layout_name:tile") (lib.range 1 6);

			layerrule = [
				"layer_name:msnap, noanim:1, noblur:1"
			];

			axisbind = axis;
			gesturebind = gestures;

			bind = [
				launch.terminal
				launch.bluetooth
				launch.wifi
				launch.audio
				launch.files
				quickshell.launcher
				quickshell.clipboard
				quickshell.emoji
				quickshell.wallpaper
				media.volup
				media.voldown
				media.mute
				media.micmute
				media.togglemic
				media.brightup
				media.brightdown
				nav.reload
				nav.kill
				nav.fullscreen
				nav.minimized
				nav.quit
				nav.lock
				nav.zoom
				nav.focuslast
				nav.focusstack
				nav.switch_layout
				nav.togglefloat
				vim_focus.left
				vim_focus.down
				vim_focus.up
				vim_focus.right
				vim_move.left
				vim_move.down
				vim_move.up
				vim_move.right
				alt_focus.left
				alt_focus.down
				alt_focus.up
				alt_focus.right
				alt_move.left
				alt_move.down
				alt_move.up
				alt_move.right
				msnap.gui
				msnap.region
				msnap.cast
				layout.set_tile
				layout.set_scroller
				layout.incmaster
				layout.decmaster
				view.left
				view.left_with_client
				view.right
				view.right_with_client
				view.tag_left
				view.tag_right
			] ++ tag_view ++ tag_move ++ tag_toggle_view ++ tag_toggle_tag;

			mousebind = mouse;
		};

		systemd = {
			enable = true;
			xdgAutostart = true;
			variables = [
				"DISPLAY"
				"WAYLAND_DISPLAY"
				"XDG_CURRENT_DESKTOP"
				"XDG_SESSION_TYPE"
				"NIXOS_OZONE_WL"
				"QT_QPA_PLATFORMTHEME"
				"QT_AUTO_SCREEN_SCALE_FACTOR"
				"QT_WAYLAND_FORCE_DPI"
				"QT_QPA_PLATFORM"
				"XCURSOR_THEME"
				"XCURSOR_SIZE"
			];
		};

		autostart_sh = ''
			foot --server &
			CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/quickshell"
			WALLPAPER_STATE="$CACHE_DIR/current-wallpaper"
			mkdir -p "$CACHE_DIR"
			if [ -f "$WALLPAPER_STATE" ]; then
				WALLPAPER="$(cat "$WALLPAPER_STATE")"
			else
				WALLPAPER=~/nixos/assets/wallpaper.jpg
			fi
			# Write JSON state so shell.qml's FileView picks it up
			cat > "$CACHE_DIR/wallpaper-state.json" << EOF
{"wallpaper_path": "$WALLPAPER"}
EOF
			quickshell --config quickshell &
		'';
	};

	xdg.configFile."xdg-desktop-portal/mango-portals.conf".text = ''
		[preferred]
		default=gtk
		org.freedesktop.impl.portal.ScreenCast=wlr
		org.freedesktop.impl.portal.Screenshot=wlr
		org.freedesktop.impl.portal.Secret=gnome-keyring
		org.freedesktop.impl.portal.Inhibit=none
	'';
}
