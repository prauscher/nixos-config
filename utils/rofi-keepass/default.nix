{
  pkgs ? import <nixpkgs> {},
  lib ? pkgs.lib,
  stdenv ? pkgs.stdenv,
}:

stdenv.mkDerivation {
  name = "rofi-keepass";
  nativeBuildInputs = with pkgs; [
    makeWrapper
  ];
  dontUnpack = true;
  installPhase = ''
    install -Dm755 ${./rofi-keepass.sh} $out/bin/rofi-keepass
    wrapProgram $out/bin/rofi-keepass --prefix PATH : ${lib.makeBinPath [ pkgs.keepassxc pkgs.keyutils pkgs.libnotify pkgs.rofi ]}
  '';
}
