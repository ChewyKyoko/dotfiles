{ mangowm }:
final: prev:
let
	scenefx_0_5 = final.callPackage ./scenefx/package.nix { };
	mangowc-unwrapped-drv = final.callPackage ./mangowc-unwrapped/package.nix {
		sources = { mangowc = mangowm; };
		wlroots = final.wlroots;
		scenefx = scenefx_0_5;
	};
in {
	inherit scenefx_0_5;

	mangowc-unwrapped = mangowc-unwrapped-drv.overrideAttrs (old: {
		postInstall = (old.postInstall or "") + ''
			# Remove the plain mango.desktop to avoid duplicate SDDM entries
			# (UWSM generates its own session entry under "Mango (UWSM)")
			rm -f $out/share/wayland-sessions/mango.desktop
			rmdir $out/share/wayland-sessions 2>/dev/null || true
		'';
	});

	mangowc = final.callPackage ./mangowm.nix { };
}
