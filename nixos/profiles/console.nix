{ pkgs, ... }: {
  security.wrappers.write = {
    setgid = true;
    owner = "root";
    group = "tty";
    source = "${pkgs.util-linux}/bin/write";
  };
  console = {
    packages = with pkgs; [ powerline-fonts terminus_font ];
    font = "ter-powerline-v24b";
    useXkbConfig = true;
    earlySetup = true;
    colors = [
      "232627"
      "ed1515"
      "11d116"
      "f67400"
      "1d99f3"
      "9b59b6"
      "1abc9c"
      "fcfcfc"
      "7f8c8d"
      "c0392b"
      "1cdc9a"
      "fdbc4b"
      "3daae9"
      "8e44ad"
      "16a085"
      "ffffff"
    ];
  };
}
