{
  # FIXME the 01xx keycodes doesn't work, error message was on the right device, probably not the bug on google
  # refer to /proc/bus/input/devices KEY bitmap?
  services.udev.extraHwdb = ''
    evdev:name:AT Translated Set 2 keyboard:*
      KEYBOARD_KEY_1d=muhenkan
      KEYBOARD_KEY_3a=leftctrl
      KEYBOARD_KEY_b8=henkan
      KEYBOARD_KEY_9d=rightalt


    evdev:name:Ideapad extra buttons:*
      KEYBOARD_KEY_0d=f16
      KEYBOARD_KEY_0107=key_f20
      KEYBOARD_KEY_010e=key_f22
      KEYBOARD_KEY_010f=key_f23
      KEYBOARD_KEY_41=capslock
      KEYBOARD_KEY_0110=key_compose
      KEYBOARD_KEY_0101=key_yen
      KEYBOARD_KEY_012a=key_102nd
      KEYBOARD_KEY_0129=ro

  '';
}
