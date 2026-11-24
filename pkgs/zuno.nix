# Zuno - YouTube Music desktop client (Tauri). Not in nixpkgs yet; package the official AppImage.
# Releases: https://github.com/noFAYZ/zuno/releases
{ appimageTools, fetchurl }:

appimageTools.wrapType2 rec {
  pname = "zuno";
  version = "1.5.0";

  src = fetchurl {
    url = "https://github.com/noFAYZ/zuno/releases/download/v${version}/Zuno_${version}_amd64.AppImage";
    hash = "sha256-wNbAIZQSGQPEZGzGZPse2hLO4H4e2kifLlVVzbyBoL8=";
  };

  meta = {
    description = "Zuno - desktop YouTube Music client";
    homepage = "https://github.com/noFAYZ/zuno";
    mainProgram = "zuno";
    platforms = [ "x86_64-linux" ];
  };
}
