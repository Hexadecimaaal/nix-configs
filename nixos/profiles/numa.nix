{ pkgs, ... }: {
  boot.kernelParams = [
    "cgroup_no_v1=cpu,cpuacct,memory,devices,freezer,net_cls,blkio,perf_event,net_prio,hugetlb,pids,rdma"
    "systemd.unified_cgroup_hierarchy=no"
  ];

  environment.systemPackages = with pkgs; [
    numad
    numactl
  ];

  systemd.services."numad" = {
    description = "numad - The NUMA daemon that manages application locality";
    documentation = [ "man:numad" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.numad}/bin/numad";
      Type = "forking";
    };
  };
}