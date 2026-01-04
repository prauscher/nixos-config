{ config, lib, pkgs, ... }:

{
  # Do not forget to use passwd to set an initial password
  users.users.prauscher = {
    isNormalUser = true;
    description = "Patrick Rauscher";
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      mtr
      iftop
      nmap
      tcpdump
      whois
      dnsutils
      python3
      openssl
      socat
      ipcalc
      usbutils
      binutils
    ];
  };

  home-manager.users.prauscher = {
    programs.git = {
      enable = true;
      package = pkgs.gitFull;
      settings = {
        user = {
          name = "Patrick Rauscher";
          email = "prauscher@prauscher.de";
        };
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        pull.rebase = true;
      };
    };
    programs.nushell = {
      enable = true;
      extraConfig = ''
        $env.config.buffer_editor = "nano";
        $env.config.show_banner = false;
        $env.LANG = "de_DE.UTF-8";
      '';
    };
    programs.fish = {
      enable = true;
    };
    services.ssh-agent = {
      enable = true;
    };
    home.sessionVariables = {
      EDITOR = "nano";
      TERMINAL = "alacritty";
      NIXOS_OZONE_WL = "1";
    };

    home.stateVersion = "24.11";
  };

  security.sudo.wheelNeedsPassword = false;
  users.defaultUserShell = pkgs.nushell;
}
