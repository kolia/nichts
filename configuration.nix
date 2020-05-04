# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, callPackage, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # boot.extraModprobeConfig = ''
  #   options snd slots=snd-hda-intel
  # '';

  # boot.blacklistedKernelModules = [ "snd_pcsp" ];

  networking.hostName = "nichts"; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.wlp108s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  console = {
    earlySetup = true;
    font = "ter-i32b";
    keyMap = "us";
    packages = with pkgs; [
      terminus_font
    ];
  };

  fonts.fontconfig.dpi = 180;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   wget vim
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  #   pinentryFlavor = "gnome3";
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    # support32Bit = true;
    extraConfig = ''
      # Automatically switch to newly connected devices.
      # load-module module-switch-on-connect
      # Discover Apple iTunes devices on network.
      # load-module module-raop-discover
    '';
    zeroconf.discovery.enable = true;
    
    # Enable extra bluetooth modules, like APT-X codec.
    extraModules = [ pkgs.pulseaudio-modules-bt ];
    
    # Enable bluetooth (among others) in Pulseaudio
    package = pkgs.pulseaudioFull;
  };
  # Make sure pulseaudio is being used as sound system
  # for the different applications as well.
  nixpkgs.config.pulseaudio = true;

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

  environment = {
    systemPackages = with pkgs; [
      kakoune
      chromium
      git
      alacritty
      ion
      starship
      redshift
      bc
      tmux
      libinput
      clipmenu
      xorg.xev
      inxi
      procs
      exa
      ripgrep
      skim
    ];

    variables = {
      EDITOR = "kak";
      TERMINAL = "alacritty";
      SHELL = "ion";
    };

    # etc."X11/xorg.conf.d/20-intel.conf" = {
    #   text = ''
    #     Section "Device"
    #     Identifier "Intel Graphics"
    #     Driver "intel"
    #     Option "TearFree" "true"
    #     Option "AccelMethod" "uxa"
    #     Option "SwapbuffersWait" "true"
    #     EndSection
    #   '';
    # };
  };

  services = {
    xserver = {
      enable = true;
      autorun = true;

      libinput = {
        enable = true;
        naturalScrolling = true;
        middleEmulation = true;
        clickMethod = "clickfinger";
        tapping = true;
      };

      desktopManager = {
        xterm.enable = false;
      };

      displayManager.lightdm.enable = true;

      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
          i3status
          rofi
        ];
      };
    };
  };

  users.defaultUserShell = pkgs.ion;

  users.users.kolia = {
    isNormalUser = true;
    home = "/home/kolia";
    description = " ";
    extraGroups = [
      "audio"                           # Access sound hardware
      "disk"                            # Access /dev/sda /dev/sdb etc.
      "networkmanager"                  # Access network manager
      "storage"                         # Access storage devices
      "video"                           # 2D/3D hardware acceleration & camera
      "wheel"                           # Access sudo command
    ];
    uid = 1000;
    shell = pkgs.ion;                  # Use ion as the default shell
  };


}

