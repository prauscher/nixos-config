{
  pkgs ? import <nixpkgs> {},
  lib ? pkgs.lib,
  stdenv ? pkgs.stdenv,
  rofi-keepass,
  lock-screen,
}:

stdenv.mkDerivation {
  name = "mymenu";
  nativeBuildInputs = with pkgs; [
    makeWrapper
  ];
  dontUnpack = true;
  installPhase = ''
    install -Dm755 ${./mymenu.sh} $out/bin/mymenu
    wrapProgram $out/bin/mymenu --prefix PATH : ${lib.makeBinPath [ pkgs.rofi pkgs.alacritty rofi-keepass lock-screen ]}
  '';
}
