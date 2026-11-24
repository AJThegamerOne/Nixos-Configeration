# Helium browser - not in nixpkgs yet, so package the official AppImage.
# Releases: https://github.com/imputnet/helium-linux/releases
#
# Widevine CDM is sourced from Google Chrome (via nixpkgs' widevine-cdm package)
# and symlinked into Helium's install dir, the same way nixpkgs does for Vivaldi.
{ appimageTools, fetchurl, lib, stdenv, widevine-cdm }:

let
  pname = "helium";
  version = "0.22.2.1";

  src = fetchurl {
    url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-x86_64.AppImage";
    hash = "sha256-8JDIESU/1ovH64lLmCoL4iHRcB937UtT9hRkma+LrgQ=";
  };

  extracted = appimageTools.extract {
    inherit pname version src;
  };

  withWidevine = stdenv.mkDerivation {
    pname = "${pname}-with-widevine";
    inherit version;
    src = extracted;

    dontConfigure = true;
    dontBuild = true;
    dontPatch = true;
    dontFixup = true;

    installPhase = ''
      runHook preInstall

      cp -r "$src/." "$out/"
      chmod -R u+w "$out"
      mkdir -p "$out/opt/helium"
      ln -sfn ${widevine-cdm}/share/google/chrome/WidevineCdm "$out/opt/helium/WidevineCdm"

      runHook postInstall
    '';
  };
in
appimageTools.wrapAppImage {
  inherit pname version src;
  contents = withWidevine;

  meta = {
    description = "Helium - private, fast and honest web browser (Chromium-based), with Widevine DRM from Google Chrome";
    homepage = "https://helium.computer";
    mainProgram = "helium";
    platforms = [ "x86_64-linux" ];
  };
}
