{ pkgs, ... }: {
  home.packages = with pkgs; [
    dpt-rp1-py zotero pdfarranger lyx
    texlive.combined.scheme-full
  ];
}
