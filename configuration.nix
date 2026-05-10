{ config, pkgs, unstablePkgs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  #boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos";

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Amsterdam";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_NL.UTF-8";
    LC_IDENTIFICATION = "nl_NL.UTF-8";
    LC_MEASUREMENT = "nl_NL.UTF-8";
    LC_MONETARY = "nl_NL.UTF-8";
    LC_NAME = "nl_NL.UTF-8";
    LC_NUMERIC = "nl_NL.UTF-8";
    LC_PAPER = "nl_NL.UTF-8";
    LC_TELEPHONE = "nl_NL.UTF-8";
    LC_TIME = "nl_NL.UTF-8";
  };

  services.xserver.enable = true;

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  environment.etc."xdg/kdeglobals".text = ''
    [General]
    ColorScheme=BreezeDark

    [KDE]
    LookAndFeelPackage=org.kde.breezedark.desktop
  '';

  services.xserver.xkb = {
    layout = "us";
    variant = "intl";
  };

  console.keyMap = "us-acentos";

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.erwin = {
    isNormalUser = true;
    description = "Erwin Olie";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "podman" ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  programs.firefox = {
    enable = true;
    policies = {
      DontCheckDefaultBrowser = true;

      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisableFirefoxAccounts = true;

      DisableAppUpdate = true;
      BackgroundAppUpdate = false;

      OfferToSaveLogins = false;
      PasswordManagerEnabled = false;
      DisableMasterPasswordCreation = true;

      ExtensionSettings = {
        "*".installation_mode = "blocked";

        "uBlock0@raymondhill.net" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          private_browsing = true;
        };

        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
        };
      };

      languagePacks = [ "nl" "en-US" ];
    };
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  programs.nix-ld.enable = true;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = [
    pkgs.xclip
    pkgs.wget
    pkgs.gh
    pkgs.gimp
    unstablePkgs.jetbrains.idea
    pkgs.slack
    pkgs.bruno
    pkgs.awscli2
    pkgs.openshift
    pkgs.signal-desktop
    pkgs.simple-scan
    #pkgs.jdk21
    pkgs.jdk25
    pkgs.nodejs
  ];
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.erwin = import ./home.nix;
  };

  environment.sessionVariables = {
    JAVA_HOME = "${pkgs.jdk25}";
  };

  system.stateVersion = "25.11";

  programs.ssh.startAgent = true;
  programs.zsh.enable = true;
}
