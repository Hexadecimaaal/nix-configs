{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    gcc
    gdb
    (lib.hiPrio clang)
    (lib.lowPrio lldb)
  ];
}
