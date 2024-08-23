{
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="tty", \
    ATTRS{idVendor}=="03f0", ATTRS{idProduct}=="0121", \
    SYMLINK+="hp4x"
  '';
}
