# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

with pkgs;
let
  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
in
let
  neighborhood-python-packages = python-packages: with python-packages; [
    pytest
    flask
    flask-sockets
    gunicorn
    requests
    websocket_client
  ]; 
  python-with-neighborhood-packages = python37.withPackages neighborhood-python-packages;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      unstable = import unstableTarball {
        config = config.nixpkgs.config;
      };
    };
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nichts"; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.nameservers = ["208.67.222.222" "8.8.8.8" "208.67.220.220"];


  # networking.networkmanager.enable = true;
  # networking.networkmanager.insertNameservers = ["8.8.8.8"];
  
  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.wlp108s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";
  console = {
    earlySetup = true;
    font = "ter-i22b";
    keyMap = "us";
    packages = with pkgs; [
      terminus_font
    ];
  };

  fonts.fontconfig.dpi = 100;

  fonts.fonts = with pkgs; [
    powerline-fonts
    font-awesome
  ];

  # Set your time zone.
  time.timeZone = "America/Montreal";

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

  programs.ssh.startAgent = true;

  # programs.tmux.extraConfig = ''
  #   run-shell ${pkgs.tmuxPlugins.yank}/share/tmux-plugins/yank/yank.tmux   
  # '';

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  hardware.bluetooth.enable = true;

  hardware.facetimehd.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    # support32Bit = true;
    extraConfig = ''
      # Automatically switch to newly connected devices.
      load-module module-switch-on-connect
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
      kak-lsp
      vim
      gcc
      llvmPackages.bintools
      cargo

      # map caps to esc
      xorg.xmodmap


      # our neighborhood app;  TODO isolate in its own env
      unstable.flutter
      unstable.androidStudioPackages.canary
      google-cloud-sdk
      python-with-neighborhood-packages
      #python37Full
      #python37Packages.pytest
      #python37Packages.flask
      #python37Packages.flask-sockets
      #python37Packages.gunicorn
      #python37Packages.requests
      # android emulator dependencies
      xorg.libXext
      xorg.libXtst
      xorg.libXrender
      xorg.libXi


      fish

      zotero
      atom
      julia_11
      chromium
      firefox
      git
      rsync
      sakura
      slack-dark
      redshift
      bc
      networkmanager
      unzip
      
      tmux

      xsel
      clipmenu
      imagemagick7
      obs-studio
      
      procs
      exa
      ripgrep
      skim
      bat
      fd
      dust
      i3status-rust

      # only for setting up / diagnostics
      xorg.xev
      mesa
      libinput
      pciutils
      inxi
      glxinfo
    ];

    variables = {
      EDITOR = "kak";
      TERMINAL = "sakura";
      SHELL = "fish";
    };
  };

  services = {
    xserver = {
      enable = true;
      autorun = true;

      videoDrivers = lib.mkForce [ "modesetting" ];

      synaptics = {
        enable = true;
        dev = "/dev/input/event*";
        twoFingerScroll = true;
        tapButtons = false;
        # accelFactor = "0.0005";
        buttonsMap = [ 1 3 2 ];
        palmDetect = true;
        additionalOptions = ''
          Option "VertScrollDelta" "-50" # scroll sensitivity, the bigger the negative number = less sensitive
          Option "HorizScrollDelta" "-50"
          Option "FingerLow" "40"
          Option "FingerHigh" "70"
          Option "Resolution" "60" # Pointer sensitivity
        '';
      };
      
      desktopManager = {
        xterm.enable = false;
      };

      displayManager.lightdm.enable = true;
      displayManager.lightdm.extraConfig = ''
        logind-check-graphical = true
      '';

      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
          i3lock
          rofi
        ];
      };
    };
  };

  users.defaultUserShell = pkgs.fish;

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
    shell = pkgs.fish;                  # Use ion as the default shell
  };


}

