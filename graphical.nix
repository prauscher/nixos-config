{ config, pkgs, lib, ... }:

{
  imports =
    [ <home-manager/nixos>
    ];

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

  services.udev.packages = with pkgs; [ gnome-settings-daemon ];
  services.accounts-daemon.enable = true;
  services.gnome.gnome-online-accounts.enable = true;
  services.gnome.gnome-keyring.enable = true;

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    # somehow required to show icon of nm-applet...
    extraPackages = with pkgs; [
      networkmanagerapplet
      gnome-themes-extra
      adwaita-icon-theme
    ];
  };

  fonts.packages = with pkgs; [
    adwaita-fonts
    noto-fonts
    liberation_ttf
    ubuntu-classic
    font-awesome
    roboto
  ];

  users.users.prauscher = {
    packages = with pkgs; [
      google-chrome
      evolution
      inkscape
      libreoffice
      firefox
      chromium
      eog
      mpv
      gedit
      vscode
      alacritty
      nextcloud-client
      gnome-secrets
      evince
      webex
      zoom-us
      gnome-control-center
      seahorse
      gnomeExtensions.appindicator
      wlr-randr
    ];
  };

  home-manager.users.prauscher = let
    modifier = "Mod4";
    terminal = "${pkgs.alacritty}/bin/alacritty";
    left = "h";
    down = "j";
    up = "k";
    right = "l";

    lock-screen = (pkgs.callPackage ./utils/lock-screen {});
    rofi-keepass = (pkgs.callPackage ./utils/rofi-keepass {});
    mymenu = (pkgs.callPackage ./utils/mymenu { rofi-keepass = rofi-keepass; lock-screen = lock-screen; });

  in {
    # allow unfree packages
    nixpkgs.config.allowUnfree = true;

    home.pointerCursor = {
      gtk.enable = true;
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };

    gtk = {
      enable = true;
      theme = {
        package = pkgs.gnome-themes-extra;
        name = "Adwaita";
      };
      iconTheme = {
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
      };
    };

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
        "${modifier}+Space" = "exec ${mymenu}/bin/mymenu";
        "${modifier}+Return" = "exec ${terminal}";
        "${modifier}+End" = "exec ${lock-screen}/bin/lock-screen";
        "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
        "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set +5%";
        "XF86AudioLowerVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioRaiseVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
        "XF86AudioMicMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle";
        "--release Print" = ''exec 'file="/tmp/screen-$(date +%Y%m%d-%H%M%S).png"; ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" "$file"; ${pkgs.eog}/bin/eog "$file"' '';
      };
      config.startup = [
        # not setting directly due to https://github.com/nix-community/home-manager/issues/5311
        { always = true; command = ''${pkgs.sway}/bin/swaymsg output "*" bg "/home/prauscher/Nextcloud/wallpapers/PXL_20251110_100555366.PANO.crop.jpg" fill''; }
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
          on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
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
      settings."org/gnome/gedit/preferences/editor" = {
        auto-indent = true;
        syntax-highlighting = true;
        insert-spaces = true;
        tabs-size = lib.gvariant.mkUint32 4;
        display-line-numbers = true;
        style-scheme-for-dark-theme-variant = "cobalt";
      };
    };
    programs.vscode = {
      enable = true;
    };
    services.mako = {
      enable = true;
      settings = {
        font = "Roboto 14";
        background-color = "#000000cc";
        text-color = "#338833ff";
        border-color = "#338833ff";
        border-radius = 5;
        border-size = 4;
        width = 500;
        height = 500;
        margin = "5";
        padding = "5";
        default-timeout = 20000;
      };
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
          command = "${pkgs.brightnessctl}/bin/brightnessctl set -n=1 30%-";
          resumeCommand = "${pkgs.brightnessctl}/bin/brightnessctl set +30%"; }
        { timeout = 60; command = "${lock-screen}/bin/lock-screen"; }
        { timeout = 300;
          command = ''${pkgs.sway}/bin/swaymsg "output * dpms off"'';
          resumeCommand = ''${pkgs.sway}/bin/swaymsg "output * dpms on"''; }
      ];
      events = [
        { event = "before-sleep"; command = "${lock-screen}/bin/lock-screen"; }
      ];
    };
    services.kanshi = {
      enable = true;
      settings = [
        {
          profile.name = "undocked";
          profile.outputs = [
            {
              criteria = "eDP-1";
              status = "enable";
            }
          ];
        }
        {
          profile.name = "dock_home";
          profile.outputs = [
            {
              criteria = "eDP-1";
              status = "disable";
            }
            {
              criteria = "Dell Inc. DELL U2415 7MT019AB0YPU";
              status = "enable";
              position = "0,0";
            }
            {
              criteria = "Dell Inc. DELL U2415 XKV0P9BI1A6L";
              status = "enable";
              position = "1920,0";
            }
          ];
        }
      ];
    };
    home.file.".config/rofi/config.rasi".text = ''
      configuration {
        modi: "drun,run,filebrowser,window";
        terminal: "alacritty";
      }
      @theme "${pkgs.rofi}/share/rofi/themes/fancy.rasi"
    '';
    home.file.".config/alacritty/alacritty.toml".text = ''
      [env]
      TERM = "xterm-256color"

      [colors.primary]
      background = "#000000"

      [window]
      opacity = 0.8
    '';

    home.stateVersion = "24.11";
  };
}
