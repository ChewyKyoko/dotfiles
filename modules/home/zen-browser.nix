{ pkgs, firefox-addons, ... }:
let
  ffAddons = firefox-addons.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;
    profiles."default" = {
      id = 0;
      isDefault = true;
      search = {
        force = true;
        default = "ddg";
        engines = {
          "ddg" = {
            urls = [{ template = "https://duckduckgo.com/?q={searchTerms}"; }];
          };
        };
      };
      extensions = {
        packages = with ffAddons; [
          ublock-origin
          proton-pass
        ];
      };
    };
    policies = {
      DisableAppUpdate = true;
      DisableTelemetry = true;
      DisablePocket = true;
      DisableFirefoxStudies = true;
      DisableFirefoxAccounts = true;
      DisableFirefoxScreenshots = true;
      OfferToSaveLogins = false;
    };
    extraPrefs = ''
      lockPref("layout.css.devPixelsPerPx", "1.25");
      lockPref("font.name.sans-serif.x-western", "Inter");
      lockPref("font.name.monospace.x-western", "Mononoki Nerd Font");
      lockPref("font.size.variable.x-western", 19);
      lockPref("browser.contentblocking.category", "strict");
      lockPref("privacy.globalprivacycontrol.enabled", true);
      lockPref("browser.uitour.enabled", false);
      lockPref("browser.download.start_downloads_in_tmp_dir", true);
      lockPref("browser.startup.homepage", "about:blank");
      lockPref("browser.newtabpage.enabled", false);
      lockPref("dom.private-attribution.submission.enabled", false);
      lockPref("privacy.sanitize.sanitizeOnShutdown", true);
      lockPref("network.trr.mode", 3);
      lockPref("network.trr.uri", "https://dns.quad9.net/dns-query");
      lockPref("media.hardware-video-decoding.force-enabled", true);
      lockPref("media.ffmpeg.vaapi.enabled", true);
      lockPref("widget.dmabuf.force-enabled", true);
    '';
  };

  stylix.targets.zen-browser = {
    enable = true;
    profileNames = [ "default" ];
  };
}
