{ config, lib, ... }:
# Firefox: privacy hardening, uBlock lists
let
	# Helper for locked Firefox preferences (betterfox-compatible)
	lock = value: { Value = value; Status = "locked"; };
in {
	options.desktop.firefox.enable =
		lib.mkEnableOption "Firefox";

	config = lib.mkIf config.desktop.firefox.enable {

		stylix.targets.firefox = {
			profileNames = [ "default" ];
			colorTheme.enable = true;
		};

		programs.firefox = {
			enable = true;
			configPath = ".mozilla/firefox";

			betterfox = {
				enable = true;
				profiles.default.enableAllSections = true;
			};

			# System-level locked policies (can't be overridden)
			policies = {
				DisableTelemetry = true;
				DisablePocket = true;
				DisableFirefoxStudies = true;
				DisableFirefoxAccounts = true;
				DisableFirefoxScreenshots = true;
				OfferToSaveLogins = false;

				# uBlock Origin: custom filter lists + settings
				"3rdparty".Extensions."uBlock0@raymondhill.net" = {
					adminSettings = {
						userSettings = {
							uiTheme = "dark";
							uiAccentCustom = true;
							uiAccentCustom0 = "#7aa2f7";
							cloudStorageEnabled = false;
							importedLists = [
								"https://raw.githubusercontent.com/DandelionSprout/adfilt/master/LegitimateURLShortener.txt"
								"https://divested.dev/hosts-domains-wildcards"
								"https://divested.dev/blocklists/Fingerprinting.ubl"
							];
						};
						selectedFilterLists = [
							"ublock-filters" "ublock-badware" "ublock-privacy"
							"ublock-unbreak" "ublock-quick-fixes"
							"easylist" "easyprivacy"
							"adguard-annoyance" "adguard-social"
							"adguard-generic" "adguard-spyware-url"
							# Custom imported lists (must be listed here to enable via policy)
							"https://raw.githubusercontent.com/DandelionSprout/adfilt/master/LegitimateURLShortener.txt"
							"https://divested.dev/hosts-domains-wildcards"
							"https://divested.dev/blocklists/Fingerprinting.ubl"
						];
					};
				};

				# Install extensions
				ExtensionSettings = {
					"uBlock0@raymondhill.net" = {
						install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
						installation_mode = "force_installed";
					};
					"proton-pass@proton.me" = {
						install_url = "https://addons.mozilla.org/firefox/downloads/latest/proton-pass/latest.xpi";
						installation_mode = "force_installed";
					};
				};

				# Locked preferences
				Preferences = {
					"browser.contentblocking.category" = lock "strict";
					"privacy.globalprivacycontrol.enabled" = lock true;
					"browser.uitour.enabled" = lock false;
					"browser.download.start_downloads_in_tmp_dir" = lock true;
					"browser.startup.homepage" = lock "about:blank";
					"browser.newtabpage.enabled" = lock false;
					"browser.toolbars.vertical" = lock true;
					"sidebar.verticalTabs" = lock true;
					"layout.css.devPixelsPerPx" = lock "1.05";
					"media.hardware-video-decoding.force-enabled" = lock true;
					"media.ffmpeg.vaapi.enabled" = lock true;
					"widget.dmabuf.force-enabled" = lock true;
					"toolkit.legacyUserProfileCustomizations.stylesheets" = lock true;

					# Privacy Guides recommendations (not covered by betterfox)
					"dom.private-attribution.submission.enabled" = lock false;  # PPA (FF128+)
					"privacy.sanitize.sanitizeOnShutdown" = lock true;         # clear cookies on close
					"network.trr.mode" = lock 3;                               # DNS-over-HTTPS, max protection
					"network.trr.uri" = lock "https://dns.quad9.net/dns-query"; # Quad9 DoH
				};
			};

			# HM profile settings (user-settable, applied via user.js)
			profiles = {
				default = {
					id = 0;
					name = "default";
					isDefault = true;
					path = "default";

					search = {
						force = true;
						default = "ddg";
						engines = {
							"ddg" = {
								urls = [{ template = "https://duckduckgo.com/?q={searchTerms}"; }];
							};
						};
					};

					extensions.force = true;
				};
			};
		};
	};
}
