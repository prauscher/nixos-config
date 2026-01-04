{ config, pkgs, lib, options, ... }:

{
  imports = [
    ../../nixos/configuration.nix
  ];

  networking.hostName = "ramona";
}
