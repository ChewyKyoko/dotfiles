{
	lib,
	mangowc-unwrapped,
	makeWrapper,
	symlinkJoin,
	writeShellScriptBin,
	dbus,
	wrapGAppsHook3,
	gdk-pixbuf,
	glib,
	gtk3,
}:
let
	mango = mangowc-unwrapped;
	baseWrapper = writeShellScriptBin mango.meta.mainProgram ''
		set -o errexit
		if [ ! "$_MANGO_WRAPPER_ALREADY_EXECUTED" ]; then
			export XDG_CURRENT_DESKTOP=${mango.meta.mainProgram}
			export _MANGO_WRAPPER_ALREADY_EXECUTED=1
		fi
		if [ "$DBUS_SESSION_BUS_ADDRESS" ]; then
			exec ${lib.meta.getExe mango} "$@"
		else
			exec ${dbus}/bin/dbus-run-session ${lib.meta.getExe mango} "$@"
		fi
	'';
in
	symlinkJoin {
		inherit (mango) meta version;
		pname = lib.strings.replaceStrings ["-unwrapped"] [""] mango.pname;
		paths = [baseWrapper mango];
		dontWrapGApps = true;
		strictDeps = false;

		nativeBuildInputs = [makeWrapper wrapGAppsHook3];

		buildInputs = [ gdk-pixbuf glib gtk3 ];

		postBuild = ''
			gappsWrapperArgsHook
			wrapProgram $out/bin/${mango.meta.mainProgram} \
				"''${gappsWrapperArgs[@]}"
		'';

		passthru = {
			inherit (mango.passthru) providedSessions uwsm-plugin;
			unwrapped = mangowc-unwrapped;
		};
	}
