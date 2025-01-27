# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, options, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  # Bootloader.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  nix.settings.auto-optimise-store = true;

  networking.hostName = "ramona";

  # Enable networking
  networking.networkmanager.enable = true;

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

  services.displayManager = {
    defaultSession = "sway";
    autoLogin = {
      enable = true;
      user = "prauscher";
    };
  };

  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "sway";
        user = "prauscher";
      };
      default_session = initial_session;
    };
  };

  # Configure console keymap
  console.keyMap = "de";

  # Enable CUPS
  services.printing.enable = true;

  services.udev.packages = with pkgs; [ gnome-settings-daemon ];
  services.accounts-daemon.enable = true;
  services.gnome.gnome-online-accounts.enable = true;

  # Configure sound
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  security.sudo.wheelNeedsPassword = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.prauscher = {
    isNormalUser = true;
    description = "Patrick Rauscher";
    extraGroups = [ "networkmanager" "wheel" "wireshark" ];
    packages = with pkgs; [
      google-chrome
      evolution
      inkscape
      libreoffice
      firefox
      chromium
      eog
      gedit
      docker
      vscode
      alacritty
      python3
      nextcloud-client
      gnome-secrets
      mtr
      iftop
      evince
      webex
      zoom
      gnome-control-center
      seahorse
      adwaita-icon-theme
      gnomeExtensions.appindicator
      wireshark
      tcpdump
      nmap
      mitmproxy
      whois
      dnsutils
      openssl
      socat
      ipcalc
    ];
  };

  users.defaultUserShell = pkgs.fish;

  home-manager.users.prauscher = let
    modifier = "Mod4";
    terminal = "${pkgs.alacritty}/bin/alacritty";
    left = "h";
    down = "j";
    up = "k";
    right = "l";

    lock_screen = pkgs.writeShellScript "lock_screen" ''
      ${pkgs.swaylock}/bin/swaylock -f -i $(${pkgs.findutils}/bin/find /home/prauscher/Nextcloud/wallpapers/ -type f | ${pkgs.coreutils-full}/bin/shuf -n 1)
    '';
    rofi-keepass = pkgs.writeShellScript "rofi-keepass" ''
      PASSWORD_DATABASE="$1"

      KEY_DESC="keepassxc:$(printf "%s" "$PASSWORD_DATABASE" | sha256sum)"
      KEY_ID=$(keyctl search @s user "$KEY_DESC" 2> /dev/null)

      if [ $? -ne 0 ]; then
        KEY_ID=$(rofi -dmenu -i -p "Enter database password" -l 0 -password -width 500 | keyctl padd user "$KEY_DESC" @s)
      fi

      keyctl pipe "$KEY_ID" | keepassxc-cli db-info -q "$PASSWORD_DATABASE"
      if [ $? -eq 1 ]; then
        rofi -e "Password invalid"
        keyctl revoke "$KEY_ID"
        exit
      fi

      PASS_ID=$(keyctl pipe "$KEY_ID" | keepassxc-cli ls -qRf "$PASSWORD_DATABASE" | rofi -dmenu -i -p "Select Password")

      if [ -z "$PASS_ID" ]; then
        exit 1
      fi

      {
        keyctl pipe "$KEY_ID" | keepassxc-cli clip -q "$PASSWORD_DATABASE" "$PASS_ID" 10
      } &
      _bgtask=$!

      USERNAME=$(keyctl pipe "$KEY_ID" | keepassxc-cli show -qa UserName "$PASSWORD_DATABASE" "$PASS_ID" 2>/dev/null)
      TOTP=$(keyctl pipe "$KEY_ID" | keepassxc-cli show -qt "$PASSWORD_DATABASE" "$PASS_ID" 2>/dev/null)
      if [ $? -eq 0 ]; then
        notify-send -t 10000 "$PASS_ID: $USERNAME" "Der TOTP-Token lautet <b>$TOTP</b>"
      else
        notify-send -t 5000 "$PASS_ID: $USERNAME" "Das Passwort wurde für 10 Sekunden in der Zwischenablage gespeichert"
      fi

      wait $_bgtask
    '';
    mymenu = pkgs.writeShellScript "mymenu" ''
      INPUT=$(rofi -dmenu -p "Menu" <<EOT
      run
      keepass
      thwkeepass
      chat
      lock
      suspend
      EOT
      )
      [ $? -ne 0 ] && exit

      OPTION=$(echo "$INPUT" | awk '{ print $1 }')
      OPTION_ARGS=$(echo "$INPUT" | awk '{ $1=""; print substr($0,1) }')

      case "$OPTION" in
      run) exec sh -c "${pkgs.rofi}/bin/rofi -show drun" ;;
      keepass) exec sh -c "${rofi-keepass} /home/prauscher/Nextcloud/Passwords.kdbx" ;;
      thwkeepass) exec sh -c "${rofi-keepass} /home/prauscher/THW/Nextcloud/3.\ Gruppen/OV-Führung/Passwörter.kdbx" ;;
      chat) exec sh -c "${pkgs.alacritty}/bin/alacritty -e sh -c 'TERM=xterm256color ssh -t shells.darmstadt.ccc.de \"tmux attach\"'" ;;
      lock) exec sh -c "${lock_screen}" ;;
      suspend) exec sh -c "systemctl suspend" ;;
      esac
    '';

  in {
    wayland.windowManager.sway = {
      enable = true;
      config.gaps.inner = 10;
      config.gaps.outer = 0;
      config.fonts = {
        names = ["Roboto"];
        size = 12.0;
      };
      config.modifier = "${modifier}";
      config.terminal = "${terminal}";
      config.bars = [
        {
          mode = "dock";
          command = "${pkgs.waybar}/bin/waybar";
        }
      ];
      config.input."*".xkb_layout = "de";
      config.input."type:touch".map_to_output = "eDP-1";
      config.output."eDP-1".scale = "1.4";
      config.workspaceAutoBackAndForth = true;
      config.keybindings = {
        "${modifier}+q" = "layout toggle all";
        "${modifier}+f" = "fullscreen";
        "${modifier}+Shift+Space" = "floating toggle";
        "${modifier}+Shift+q" = "kill";
        "${modifier}+Shift+c" = "reload";
        "${modifier}+${left}" = "focus left";
        "${modifier}+${right}" = "focus right";
        "${modifier}+${up}" = "focus up";
        "${modifier}+${down}" = "focus down";
        "${modifier}+Shift+${left}" = "move left";
        "${modifier}+Shift+${right}" = "move right";
        "${modifier}+Shift+${up}" = "move up";
        "${modifier}+Shift+${down}" = "move down";
        "${modifier}+Control+${left}" = "focus parent";
        "${modifier}+Control+${right}" = "focus child";
        "${modifier}+Control+${up}" = "splith";
        "${modifier}+Control+${down}" = "splitv";
        "${modifier}+1" = "workspace number 1";
        "${modifier}+2" = "workspace number 2";
        "${modifier}+3" = "workspace number 3";
        "${modifier}+4" = "workspace number 4";
        "${modifier}+5" = "workspace number 5";
        "${modifier}+6" = "workspace number 6";
        "${modifier}+7" = "workspace number 7";
        "${modifier}+8" = "workspace number 8";
        "${modifier}+9" = "workspace number 9";
        "${modifier}+0" = "workspace number 10";
        "${modifier}+Shift+1" = "move container to workspace number 1";
        "${modifier}+Shift+2" = "move container to workspace number 2";
        "${modifier}+Shift+3" = "move container to workspace number 3";
        "${modifier}+Shift+4" = "move container to workspace number 4";
        "${modifier}+Shift+5" = "move container to workspace number 5";
        "${modifier}+Shift+6" = "move container to workspace number 6";
        "${modifier}+Shift+7" = "move container to workspace number 7";
        "${modifier}+Shift+8" = "move container to workspace number 8";
        "${modifier}+Shift+9" = "move container to workspace number 9";
        "${modifier}+Shift+0" = "move container to workspace number 10";
        "${modifier}+Space" = "exec ${mymenu}";
        "${modifier}+Return" = "exec ${terminal}";
        "${modifier}+End" = "exec ${lock_screen}";
        "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
        "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set +5%";
        "XF86AudioLowerVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioRaiseVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
        "XF86AudioMicMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle";
        "--release Print" = ''exec 'file="/tmp/screen-$(date +%Y%m%d-%H%M%S).png"; ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" "$file"; eog "$file"' '';
      };
      config.startup = [
        # not setting directly due to https://github.com/nix-community/home-manager/issues/5311
        { always = true; command = ''${pkgs.sway}/bin/swaymsg output "*" bg "/home/prauscher/Nextcloud/wallpapers/PXL_20231004_110951659.jpg" fill''; }
        { command = "${pkgs.mako}/bin/mako"; }
        { command = "${pkgs.dex}/bin/dex -a"; }
      ];
      config.focus.wrapping = "yes";
      config.colors.focused.border = "#003399";
      config.colors.focused.background = "#003399";
      config.colors.focused.text = "#ffffff";
      config.colors.focused.indicator = "#003399";
      config.colors.focused.childBorder = "#003399";
      config.colors.focusedInactive.border = "#222222";
      config.colors.focusedInactive.background = "#222222";
      config.colors.focusedInactive.text = "#bbbbbb";
      config.colors.focusedInactive.indicator = "#222222";
      config.colors.focusedInactive.childBorder = "#222222";
      config.colors.unfocused.border = "#222222";
      config.colors.unfocused.background = "#222222";
      config.colors.unfocused.text = "#bbbbbb";
      config.colors.unfocused.indicator = "#222222";
      config.colors.unfocused.childBorder = "#222222";
      extraConfig = ''
        default_border none
        default_floating_border none
      '';
    };
    programs.waybar = {
      enable = true;
      style = ''
        * {
          font-family: Roboto, sans-serif;
          font-size: 16px;
          min-height: 0;
        }

        #tray menu {
          border: 1px solid #eeeeee;
          padding: 5px 1px;
          background: #111111;
          color: #eeeeee;
        }
        #tray menu separator {
          background: #eeeeee;
          min-height: 1px;
          margin: 2px 0px;
        }
        #tray menu arrow, #tray menu check, #tray menu radio {
          min-height: 10px;
          min-width: 10px;
        }
        #tray menu menuitem {
          background: transparent;
          color: #eeeeee;
        }
        #tray menu menuitem:disabled {
          color: #999999;
        }
        #tray menu menuitem:hover {
          background: #444444;
        }

        window#waybar {
          background: #000000;
          color: #ffffff;
        }

        #workspaces button {
          padding: 0 5px;
          background-color: transparent;
          border-radius: 0;
          color: #ffffff;
          /* Use box-shadow instead of border so the text isn't offset */
          box-shadow: inset 0 -3px transparent;
        }
        #workspaces button:hover {
          background: rgba(0,0,0,0.2);
          box-shadow: inset 0 -3px #ffffff;
        }
        #workspaces button.focused {
          background: #64727d;
          box-shadow: inset 0 -3px #ffffff;
        }
        #workspaces button.urgent {
          box-shadow: inset 0 -3px #eb4d4b;
        }

        /* omit outermost margins */
        .modules-left > widget:first-child > #workspaces {
          margin-left: 0;
        }
        .modules-right > widget:last-child > #workspaces {
          margin-right: 0;
        }

        #clock, #battery, #backlight, #network, #pulseaudio, #tray, #mode, #idle_inhibitor {
          padding: 0 10px;
          margin: 0 4px;
        }
        #window, #workspaces {
          margin: 0 4px;
        }

        @keyframes blink {
          to {
            background-color: #ffffff;
            color: #000000;
          }
        }
        #battery.critical:not(.charging) {
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
        }

        #mode {
          border-bottom: 2px solid #ffffff;
        }
        #idle_inhibitor {
          border-bottom: 2px solid #2d3436;
        }
        #idle_inhibitor.activated {
          border-bottom: 2px solid #ecf0f1;
        }
        #backlight {
          border-bottom: 2px solid #2ecc71;
        }
        #network {
          border-bottom: 2px solid #9b59b6;
        }
        #pulseaudio {
          border-bottom: 2px solid #f1c40f;
        }
        #battery {
          border-bottom: 2px solid #ffffff;
        }
        #clock { 
          border-bottom: 2px solid #64727d;
        }
        #tray {
          border-bottom: 2px solid #2980b9;
        }
      '';
      settings = [{
        position = "bottom";
        height = 30;
        modules-left = ["sway/workspaces" "sway/mode"];
        modules-center = ["sway/window"];
        modules-right = ["idle_inhibitor" "pulseaudio" "network" "backlight" "battery#BAT0" "clock" "tray"];
        "sway/mode" = {
          format = ''<span style="italic">{}</span>'';
        };
        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "";
            deactivated = "";
          };
        };
        pulseaudio = {
          format = "{volume}% {icon} {format_source}";
          format-bluetooth = "{volume}% {icon}  {format_source}";
          format-bluetooth-muted = " {icon}  {format_source}";
          format-muted = " {format_source}";
          format-source = "{volume}% ";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = ["" "" ""];
          };
          on-click = "pavucontrol";
        };
        network = {
          format-wifi = "{essid} ";
          format-ethernet = "{ipaddr}/{cidr} ";
          format-linked = "(no IP) ";
          disconnected = "Disconnected ⚠";
          format-alt = "{ifname}: {ipaddr}/{cidr}";
        };
        backlight = {
          format = "{percent}% {icon}";
          format-icons = ["" ""];
        };
        "battery#BAT0" = {
          bat = "BAT0";
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-charging = "{capacity}% ";
          format-plugged = "{capacity}% ";
          format-icons = ["" "" "" "" ""];
        };
        clock = {
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          calendar-weeks-pos = "left";
          today-format = ''<span color="#ff6699"><b><u>{}</u></b></span>'';
          format-calender = ''<span color="#ecc6d9"><b>{}</b></span>'';
          format-calender-weeks = ''<span color="#99ffdd"><b>W{:%V}</b></span>'';
          format = "{:%d %H:%M %b %y}";
          format-alt = "{:%H:%M:%S}";
        };
        tray = {
          spacing = 10;
        };
      }];
    };
    dconf = {
      enable = true;
      settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
    };
    programs.git = {
      enable = true;
      userName = "Patrick Rauscher";
      userEmail = "prauscher@prauscher.de";
      extraConfig.init.defaultBranch = "main";
    };
    services.mako = {
      enable = true;
      font = "Roboto 14";
      backgroundColor = "#000000cc";
      textColor = "#338833ff";
      borderColor = "#338833ff";
      borderRadius = 5;
      borderSize = 4;
      width = 500;
      height = 500;
      margin = "5";
      padding = "5";
    };
    services.nextcloud-client = {
      enable = true;
      startInBackground = true;
    };
    services.network-manager-applet.enable = true;
    services.swayidle = {
      enable = true;
      timeouts = [
        { timeout = 50;
          command = "${pkgs.brightnessctl}/bin/brightnessctl set -n 1 30%-";
          resumeCommand = "${pkgs.brightnessctl}/bin/brightnessctl set +30%"; }
        { timeout = 60; command = "${lock_screen}"; }
        { timeout = 300;
          command = ''${pkgs.sway}/bin/swaymsg "output * dpms off"'';
          resumeCommand = ''${pkgs.sway}/bin/swaymsg "output * dpms on"''; }
      ];
      events = [
        { event = "before-sleep"; command = "${lock_screen}"; }
      ];
    };
    home.packages = with pkgs; [
      keyutils
      keepassxc
      killall
    ];
    home.sessionVariables = {
      EDITOR = "nano";
      TERMINAL = "alacritty";
      NIXOS_OZONE_WL = "1";
    };
    home.file.".config/rofi/config.rasi".text = ''
      configuration {
        modi: "drun,run,filebrowser,window";
        terminal: "alacritty";
      }
      @theme "${pkgs.rofi}/share/rofi/themes/fancy.rasi"
    '';
    home.file.".config/alacritty/alacritty.toml".text = ''
      [colors.primary]
      background = "#000000"

      [window]
      opacity = 0.8
    '';

    home.stateVersion = "24.11";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  fonts.packages = with pkgs; [
    noto-fonts
    liberation_ttf
    ubuntu_font_family
    font-awesome
    roboto
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    curl
    wget
    htop
    jq
    git
    bluez
  ];

  services.gnome.gnome-keyring.enable = true;

  programs.fish.enable = true;

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      brightnessctl
      swayidle
      swaylock
      rofi
      grim
      slurp
      wl-clipboard
      mako
      libnotify
      dex
      pavucontrol
      pulseaudio
      networkmanagerapplet
    ];
  };

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
