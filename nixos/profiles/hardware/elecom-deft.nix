{ pkgs, lib, ... }: {
  services.xserver.inputClassSections = lib.mkForce [
    ''
      Identifier "DEFT Trackball config"
      MatchProduct "ELECOM TrackBall Mouse DEFT Pro TrackBall Mouse"
      Option "ButtonMapping" "1 10 3 4 5 6 7 8 9 2 11 12"
      Option "ScrollButton" "11"
      Option "ScrollMethod" "button"
    ''
  ];
  # enable wakeup
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEMS=="usb", \
    ENV{ID_SERIAL}=="ELECOM_TrackBall_Mouse_DEFT_Pro_TrackBall", \
    RUN+="${pkgs.runtimeShell} -c 'echo enabled > /sys$env{DEVPATH}/power/wakeup'"
  '';
}
