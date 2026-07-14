{
	lib,
	stdenv,
	fetchFromGitHub,
	meson,
	ninja,
	wlroots,
	scdoc,
	pkg-config,
	wayland,
	libdrm,
	libxkbcommon,
	pixman,
	wayland-protocols,
	libGL,
	libgbm,
	libxcb,
	libxcb-wm,
	lcms2,
	validatePkgConfig,
	testers,
	wayland-scanner,
}:

stdenv.mkDerivation (finalAttrs: {
	pname = "scenefx";
	version = "0.5";

	src = fetchFromGitHub {
		owner = "wlrfx";
		repo = "scenefx";
		tag = finalAttrs.version;
		hash = "sha256-vUjLG6eubEhJJVa9LPygIcVmNoHwYbSUTJcWEcbxnU4=";
	};

	strictDeps = true;

	depsBuildBuild = [ pkg-config ];

	nativeBuildInputs = [
		meson
		ninja
		pkg-config
		scdoc
		validatePkgConfig
		wayland-scanner
	];

	buildInputs = [
		libdrm
		libGL
		libxkbcommon
		libgbm
		libxcb
		libxcb-wm
		pixman
		wayland
		wayland-protocols
		wlroots
		lcms2
	];

	passthru.tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

	meta = {
		description = "Drop-in replacement for the wlroots scene API that allows wayland compositors to render surfaces with eye-candy effects";
		homepage = "https://github.com/wlrfx/scenefx";
		changelog = "https://github.com/wlrfx/scenefx/releases/tag/${finalAttrs.version}";
		license = lib.licenses.mit;
		maintainers = [ ];
		mainProgram = "scenefx";
		pkgConfigModules = [ "scenefx-0.5" ];
		platforms = lib.platforms.all;
	};
})
