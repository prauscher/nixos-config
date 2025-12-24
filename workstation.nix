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

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  users.users.prauscher.extraGroups = [ "docker" "wireshark" ];
}
