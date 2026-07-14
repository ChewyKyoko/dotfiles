# adapted from
# https://github.com/DreamMaoMao/mangowc/blob/main/nix/default.nix
{
	sources,
	lib,
	libx11,
	libinput,
	libxcb,
	libxkbcommon,
	pcre2,
	cjson,
	pixman,
	pkg-config,
	stdenv,
	wayland,
	wayland-protocols,
	wayland-scanner,
	libxcb-wm,
	xwayland,
	meson,
	ninja,
	scenefx,
	wlroots,
	libGL,
	libdrm,
	pango,
	enableXWayland ? true,
	debug ? false,
}:
stdenv.mkDerivation {
	pname = "mango-unwrapped";
	version =
		if (sources.mangowc ? version)
		then sources.mangowc.version
		else "nightly";

	src = sources.mangowc;
	mesonFlags = with lib; [
		(mesonEnable "xwayland" enableXWayland)
		(mesonBool "asan" debug)
	];

	nativeBuildInputs = [
		meson
		ninja
		pkg-config
		wayland-scanner
	];

	buildInputs =
		[
			libinput
			libxcb
			libxkbcommon
			pcre2
			cjson
			pixman
			wayland
			wayland-protocols
			wlroots
			scenefx
			libGL
			libdrm
			pango
		]
		++ lib.optionals enableXWayland [
			libx11
			libxcb-wm
			xwayland
		];

	passthru = {
		providedSessions = ["mango"];
		uwsm-plugin = ./mango-plugin.sh;
	};

	meta = {
		mainProgram = "mango";
		description = "A streamlined but feature-rich Wayland compositor";
		homepage = "https://github.com/DreamMaoMao/mango";
		license = lib.licenses.gpl3Plus;
		maintainers = [];
		platforms = lib.platforms.unix;
	};
}
