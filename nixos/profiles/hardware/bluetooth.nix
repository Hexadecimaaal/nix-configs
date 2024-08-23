{ lib, config, ... }: {
  hardware.bluetooth.enable = true;
  systemd.services."bluetooth".serviceConfig.ExecStart =
    let
      args = [ "-f" "/etc/bluetooth/main.conf" "-E" ];
    in
    lib.mkOverride 10 [
      ""
      "${config.hardware.bluetooth.package}/libexec/bluetooth/bluetoothd ${lib.escapeShellArgs args}"
    ];
}
