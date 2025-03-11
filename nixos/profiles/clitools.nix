{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    nfs-utils
    wget
    vim
    emacs
    git
    unar
    p7zip
    xz
    home-manager
    podman-compose
    pciutils
    usbutils
    sanoid
    mbuffer
    lzop
    jq
    wireguard-tools
  ];
}
