{
  gcc,
  upx,
  lib,
  unzip,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  ...
}:
stdenv.mkDerivation rec {
  pname = "snell-server";
  version = "5.0.0";
  src =
    if stdenv.hostPlatform.system == "x86_64-linux" then
      fetchurl {
        url = "https://dl.nssurge.com/snell/snell-server-v${version}-linux-amd64.zip";
        sha256 = "sha256-iTp75PxeaVuXrLgK+aSpm5mGf4y0dnhHJaP4n6I5QOE=";
      }
    else if stdenv.hostPlatform.system == "aarch64-linux" then
      fetchurl {
        url = "https://dl.nssurge.com/snell/snell-server-v${version}-linux-aarch64.zip";
        sha256 = "sha256-imp36CgZGQeD4eWf+kPep55sM42lHQvwDobfVV9ija0=";
      }
    else
      throw "Unsupported architecture: ${stdenv.hostPlatform.system}";
  nativeBuildInputs = [
    upx
    unzip
    autoPatchelfHook
  ];
  buildInputs = [
    gcc.cc.lib
  ];
  unpackPhase = ''
    unzip $src
    upx -d snell-server
  '';
  installPhase = ''
    install -Dm755 snell-server $out/bin/snell-server
  '';
  meta = {
    description = "Snell is a lean encrypted proxy protocol developed by Surge team";
    homepage = "https://kb.nssurge.com/surge-knowledge-base/release-notes/snell";
    license = lib.licenses.unfree;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
