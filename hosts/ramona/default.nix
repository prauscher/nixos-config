{ config, pkgs, lib, options, ... }:

{
  imports = [
    ./hardware.nix
    ../../nixos/configuration.nix
  ];

  networking.hostName = "ramona";
}
