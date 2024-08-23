{ lib, stdenv, fetchFromGitHub, cmake, nlohmann_json, libbpf, zlib, libelf }:

stdenv.mkDerivation rec {
  pname = "cgproxy";
  version = "0.20";
  src = fetchFromGitHub {
    owner = "springzfx";
    repo = "cgproxy";
    rev = "v${version}";
    sha256 = "sha256-mI57YGB0wG2ePHb8HXFth6g7QXrz8x5gGv2or0oBrEA=";
  };
  nativeBuildInputs = [
    cmake
    nlohmann_json
  ];
  buildInputs = [
    libbpf
    zlib
    libelf
  ];
  patchPhase = ''
    substituteInPlace src/cgproxyd.hpp --replace "DEFAULT_CONFIG_FILE" "\"/etc/cgproxy/config.json\""
  '';
  cmakeFlags = [
    "-DDEFAULT_CONFIG_FILE=/etc/cgproxy/config.json"
    "-DCMAKE_BUILD_TYPE=Release"
    "-Dbuild_execsnoop_dl=ON"
    "-Dbuild_static=OFF"
  ];
}
