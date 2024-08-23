{ lib, pkgs, ... }: {
  # security.doas.enable = true;
  # environment.systemPackages = with pkgs; [ doas-sudo-shim ];
  # Configure doas
  # security.doas.extraRules = [{
  #   groups = [ "wheel" ];
  #   keepEnv = true;
  #   persist = true;
  #   setEnv = [
  #     "HOME"
  #   ];
  # }];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    enableExtraSocket = true;
    enableBrowserSocket = true;
    # pinentryFlavor = "gnome3";
  };

  programs.ssh.extraConfig = ''
    Match host * exec "${pkgs.gnupg}/bin/gpg-connect-agent UPDATESTARTUPTTY /bye"
  '';

  services.pcscd = {
    enable = true;
    plugins = [ pkgs.ccid ];
  };

  security.pam = {
    # u2f.control = "sufficient";
    # u2f.cue = true;
    services = {
      # doas.u2fAuth = true;
      kwallet = {
        name = "kwallet";
        enableKwallet = true;
      };
    };
  };

  services.gnome.gnome-keyring.enable = true;

  # boot.initrd = {
  #   extraUtilsCommands = ''
  #     copy_bin_and_libs ${pkgs.gnupg}/bin/gpg
  #     copy_bin_and_libs ${pkgs.gnupg}/bin/gpg-agent
  #     #copy_bin_and_libs ${pkgs.gnupg}/bin/gpg-connect-agent
  #     copy_bin_and_libs ${pkgs.gnupg}/libexec/scdaemon
  #     #copy_bin_and_libs ${pkgs.pinentry.tty}/bin/pinentry-tty
  #   '';

  #   extraUtilsCommandsTest = ''
  #     $out/bin/gpg --version
  #     $out/bin/gpg-agent --version
  #     #$out/bin/gpg-connect-agent --version
  #     $out/bin/scdaemon --version
  #     #$out/bin/pinentry-tty --version
  #   '';

  #   postDeviceCommands = lib.mkAfter ''
  #     gpg-agent --daemon \
  #       --scdaemon-program ${pkgs.gnupg}/libexec/scdaemon \
  #       --allow-loopback-pinentry

  #     zfs list -H -o name | while IFS= read -r dataset; do
  #       pubkey="$(zfs get -H -o value ca.hexade:gpg-pubkey "$dataset")"
  #       if [ "$pubkey" != "-" ]; then
  #         echo "$pubkey" | base64 -d | gpg --import
  #       fi
  #     done

  #     gpg --card-status > /dev/null 2> /dev/null

  #     while ! gpg --card-status > /dev/null 2> /dev/null; do
  #       read -p "GPG smartcard not present. try again? (Y/n)" input
  #       if [ "$input" == "n" -o "$input" == "N" ]; then
  #         break
  #       fi
  #     done

  #     exec 13< <(zfs list -H -o name)
  #     while IFS= read -r dataset <&13; do
  #       cipher="$(zfs get -H -o value ca.hexade:gpg-cipher "$dataset")"
  #       if [ "$cipher" != "-" ]; then
  #         for i in $(seq 3); do
  #           read -s -p "enter GPG smartcard PIN:" pin
  #           echo "$cipher" | base64 -d \
  #           | gpg --batch --decrypt --pinentry-mode loopback \
  #             --passphrase-file <(echo "$pin") \
  #           | zfs load-key "$dataset"
  #           if [ "$?" == 0 ]; then break; fi
  #         done
  #       fi
  #     done
  #     exec 13<&-

  #     zfs load-key -a
  #   '';
  # };

}
