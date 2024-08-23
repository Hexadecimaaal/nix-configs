{ config, ... }: {
  sops.secrets.gitlab-authtoken-test = { };
  sops.secrets.gitlab-authtoken-lostmark = { };
  boot.kernel.sysctl."net.ipv4.ip_forward" = true;
  virtualisation.docker = {
    enable = true;
    storageDriver = "overlay2";
  };
  networking.firewall.checkReversePath = "loose";
  services.gitlab-runner = {
    enable = true;
    settings = {
      check_interval = 1;
      concurrent = 3;
    };
    services = {
      test = {
        authenticationTokenConfigFile = config.sops.secrets.gitlab-authtoken-test.path;
        dockerImage = "alpine";
      };
      lostmark = {
        authenticationTokenConfigFile = config.sops.secrets.gitlab-authtoken-lostmark.path;
        dockerImage = "alpine";
      };
    };
  };
}
