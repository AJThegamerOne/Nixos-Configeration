# Helium browser - not in nixpkgs yet, so package the official AppImage.
# Releases: https://github.com/imputnet/helium-linux/releases
{ appimageTools, fetchurl, lib }:

appimageTools.wrapType2 rec {
  pname = "helium";
  version = "0.22.2.1";

  src = fetchurl {
    url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-x86_64.AppImage";
    hash = "sha256-8JDIESU/1ovH64lLmCoL4iHRcB937UtT9hRkma+LrgQ=";
  };

  meta = {
    description = "Helium - private, fast and honest web browser (Chromium-based)";
    homepage = "https://helium.computer";
    mainProgram = "helium";
    platforms = [ "x86_64-linux" ];
  };
}
