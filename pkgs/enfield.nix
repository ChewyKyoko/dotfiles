{ stdenvNoCC }:
stdenvNoCC.mkDerivation {
  name = "enfield-assets";
  src = ../assets/enfield;
  dontBuild = true;
  installPhase = ''
    mkdir -p $out/share/enfield
    cp $src/bg.mp4 $out/share/enfield/
    cp $src/Main.qml $out/share/enfield/
    cp $src/BackgroundVideo.qml $out/share/enfield/
    cp $src/theme.conf $out/share/enfield/
    cp $src/metadata.desktop $out/share/enfield/
    cp -r $src/font $out/share/enfield/
    cp -r $src/shim $out/share/enfield/
    cp -r $src/imports $out/share/enfield/
    mkdir -p $out/share/sddm/themes/enfield
    ln -sf $out/share/enfield/bg.mp4 $out/share/sddm/themes/enfield/bg.mp4
    ln -sf $out/share/enfield/Main.qml $out/share/sddm/themes/enfield/Main.qml
    ln -sf $out/share/enfield/BackgroundVideo.qml $out/share/sddm/themes/enfield/BackgroundVideo.qml
    ln -sf $out/share/enfield/theme.conf $out/share/sddm/themes/enfield/theme.conf
    ln -sf $out/share/enfield/metadata.desktop $out/share/sddm/themes/enfield/metadata.desktop
    ln -sf $out/share/enfield/font $out/share/sddm/themes/enfield/font
  '';
}
