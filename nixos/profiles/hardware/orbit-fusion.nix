{ pkgs, lib, ... }: {
  # disable wakeup
  # services.udev.extraRules = ''
  #   ACTION=="add", SUBSYSTEMS=="usb", \
  #   ENV{ID_SERIAL}=="Kensington_Orbit_Fusion_Wireless_Trackball", \
  #   ATTR{power/wakeup}="disabled"
  # '';
}
