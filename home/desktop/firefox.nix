{ pkgs, ... }: {
  home.packages = with pkgs; [
    firefox
    vdhcoapp
    ungoogled-chromium
  ];

  home.file.".mozilla/native-messaging-hosts/net.downloadhelper.coapp.json".source =
    "${pkgs.vdhcoapp}/lib/mozilla/native-messaging-hosts/net.downloadhelper.coapp.json";
}
