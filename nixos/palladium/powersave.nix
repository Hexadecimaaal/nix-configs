{ lib, ... }: {
  powerManagement.enable = true;
  services.power-profiles-daemon.enable = lib.mkForce false;
  # powerManagement.powertop.enable = true;
  services.upower.enable = true;
  services.tlp.enable = true;
  services.tlp.settings = {
    PCIE_ASPM_ON_BAT = "powersupersave";
    CPU_SCALING_GOVERNOR_ON_AC = "performance";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    CPU_ENERGY_PREF_POLICY_ON_AC = "performance";
    CPU_ENERGY_PREF_POLICY_ON_BAT = "power";
    PLATFORM_PROFILE_ON_AC = "performance";
    PLATFORM_PROFILE_ON_BAT = "low-power";
    DISK_DEVICES = "nvme0n1 sda";
    # CPU_MAX_PERF_ON_BAT = 10;
  };

  boot.kernelParams = [ "nvme.noacpi=1" ];
}
