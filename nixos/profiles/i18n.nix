{ pkgs, ... }: {
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [ fcitx5-rime fcitx5-mozc rime-data ];
  };

  # workaround for rime
  environment.profileRelativeSessionVariables.QT_PLUGIN_PATH = [ "/${pkgs.qt6.qtbase.qtPluginPrefix}" ];

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [ "all" ];
  i18n.extraLocaleSettings = {
    LC_MEASUREMENT = "fi_FI.UTF-8";
    LC_MONETARY = "fi_FI.UTF-8";
    LC_NAME = "C";
    LC_PAPER = "fi_FI.UTF-8";
    LC_TELEPHONE = "fi_FI.UTF-8";
    LC_TIME = "fi_FI.UTF-8";
  };

}
