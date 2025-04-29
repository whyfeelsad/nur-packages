# https://t.me/nixos_zhcn/590965
{
  gcc,
  lib,
  upx,
  glibc,
  unzip,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  ...
}:
stdenv.mkDerivation rec {
  pname = "snell-server";
  version = "4.1.1";
  src =
    if stdenv.hostPlatform.system == "x86_64-linux"
    then
      fetchurl {
        url = "https://dl.nssurge.com/snell/snell-server-v${version}-linux-amd64.zip";
        sha256 = "sha256-zCJxt5x1BoiLNOZR6HQbOqf8fV9gqmXvi7CW8zE6GTs=";
      }
    else if stdenv.hostPlatform.system == "aarch64-linux"
    then
      fetchurl {
        url = "https://dl.nssurge.com/snell/snell-server-v${version}-linux-aarch64.zip";
        sha256 = "sha256-ONTNwD3Ns2CK+FlN+D4XlSZRZ/r8XYAvgVFIkIkC11g=";
      }
    else throw "Unsupported architecture: ${stdenv.hostPlatform.system}";
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
  meta = with lib; {
    homepage = "https://manual.nssurge.com/others/snell.html";
    platforms = ["x86_64-linux" "aarch64-linux"];
  };
}
