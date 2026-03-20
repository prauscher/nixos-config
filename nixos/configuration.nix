# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, inputs, pkgs, lib, options, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./user-base.nix
      ./graphical.nix
      ./workstation.nix
    ];

  # Bootloader.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Maintenance
  nix.settings.auto-optimise-store = true;

  # auto upgrade
  system.autoUpgrade = {
    enable = true;
    flake = inputs.self.outPath;
    flags = [
      "-L"  # print build logs
    ];
    dates = "02:00";
    randomizedDelaySec = "45min";
    runGarbageCollection = true;
  };

  nix.gc = {
    # run during autoUpgrade
    options = "--delete-older-than 7d";
  };

  # Enable networking
  networking.networkmanager = {
    enable = true;
    settings.connectivity = {
      enabled = true;
      # uri = "https://prauscher.de/check_network_status.txt";
      uri = "http://nmcheck.gnome.org/check_network_status.txt";
      interval = 90;
    };
  };
  users.users.prauscher.extraGroups = [ "networkmanager" ];

  hardware.bluetooth.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Configure console keymap
  console.keyMap = "de";

  # Enable CUPS
  services.printing = {
    enable = true;
    drivers = with pkgs; [ postscript-lexmark hplip ];
  };
  hardware.printers = {
    ensureDefaultPrinter = "Home_Lexmark";
    ensurePrinters = [
      {
        name = "Home_Lexmark";
        description = "Lexmark CX317dn";
        location = "Home";
        deviceUri = "ipp://172.22.153.132/ipp/print";
        model = "postscript-lexmark/Lexmark-CX310_Series-Postscript-Lexmark.ppd";
        ppdOptions = {
          PageSize = "A4";
          Duplex = "None";  # duplex unit is broken
        };
      }
      {
        name = "Eltern_ColorLaserjet";
        description = "HP Color LaserJet Pro MFP M479fdn";
        location = "Eltern";
        deviceUri = "socket://172.22.121.157:9100";
        model = "HP/hp-color_laserjet_pro_m479-ps.ppd.gz";
        ppdOptions = {
          PageSize = "A4";
          sides = "two-sided-long-edge";
        };
      }
    ];
  };

  # Configure sound
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    curl
    wget
    htop
    jq
    psmisc  # for killall
    bluez
    unzip
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
