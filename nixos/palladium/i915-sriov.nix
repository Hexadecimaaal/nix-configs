{ lib, pkgs, ... }: {
  boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_6_1.override {
    argsOverride = {
      src = pkgs.fetchFromGitHub {
        owner = "intel";
        repo = "linux-intel-lts";
        rev = "refs/tags/lts-v6.1.38-rt12-preempt-rt-230905T150057Z";
        sha256 = "sha256-P3EyDekNcxnFkDtESgz79t0lvWW0OgtOvDV+xvUW2YY=";
      };
      version = "6.1.38";
      modDirVersion = "6.1.38";
    };
    ignoreConfigErrors = true;
  });
  boot.kernelParams = [ "intel_iommu=on" "iommu=pt" "i915.enable_guc=3" "i915.max_vfs=7" ];
}
