{ pkgs, ... }: {
  home.file = let
    directory = if pkgs.stdenv.isLinux then
      ".local/share/fcitx5/rime"
      else if pkgs.stdenv.isDarwin then
      "Library/Rime"
      else null;
  in {
    "${directory}/default.custom.yaml".source = ./default.custom.yaml;
    "${directory}/luna_pinyin.custom.yaml".source = ./luna_pinyin.custom.yaml;
  };
}
