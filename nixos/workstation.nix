{ config, pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      # avoid DB-wifi addresses
      default-address-pools = [
        {
          base = "172.31.0.0/16";
          size = 24;
        }
      ];
    };
  };

  nixpkgs.config.permittedInsecurePackages = [
    "docker-28.5.2"
  ];

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  users.users.prauscher.extraGroups = [ "docker" "wireshark" ];
}
