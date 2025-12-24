{
  pkgs ? import <nixpkgs> {},
  lib ? pkgs.lib,
  stdenv ? pkgs.stdenv,
}:

stdenv.mkDerivation {
  name = "lock-screen";
  nativeBuildInputs = with pkgs; [
    makeWrapper
  ];
  dontUnpack = true;
  installPhase = ''
    install -Dm755 ${./lock-screen.sh} $out/bin/lock-screen
    wrapProgram $out/bin/lock-screen --prefix PATH : ${lib.makeBinPath [ pkgs.swaylock pkgs.findutils pkgs.coreutils-full ]}
  '';
}
