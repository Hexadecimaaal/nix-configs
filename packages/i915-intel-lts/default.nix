{ stdenv, lib, fetchFromGitHub, kernel }:

stdenv.mkDerivation {
  name = "i915-intel-lts-${kernel.version}";
  version = "0";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "linux-intel-lts";
    rev = "refs/tags/lts-v6.1.33-linux-230625T143228Z";
    sha256 = "sha256-hMZq9Q+64xhVCJufsNZHJaXaW0pcEPj1gtvvVj+uMgw=";
  };

  # sourceRoot = "source/drivers/gpu/drm/i915";
  hardeningDisable = [ "pic" "format" ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  postPatch = ''
    sed -i 's,subdir-ccflags-y += -I$(srctree)/$(src),subdir-ccflags-y := -I'"$(pwd)"'/include $(subdir-ccflags-y) -I$(src),g' drivers/gpu/drm/i915/Makefile
  '';

  makeFlags = [
    "-C${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "INSTALL_MOD_PATH=$(out)"
    "M=$(PWD)/drivers/gpu/drm/i915"
  ];

  installTargets = "modules_install";

  meta = with lib; {
    description = "yeet";
    homepage = "https://github.com/intel/linux-intel-lts";
    platforms = platforms.linux;
  };
}
