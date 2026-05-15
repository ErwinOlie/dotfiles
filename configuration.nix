{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.erwin = {
    isNormalUser = true;
    description = "Erwin Olie";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" ];

    # Extra group(s) kept for later.
    # extraGroups = [ "networkmanager" "wheel" "docker" ];

    # Optional user packages kept for later.
    # packages = with pkgs; [ kdePackages.kate ];
  };

  # Minimal shell support.
  programs.zsh.enable = true;

  # Keep flakes enabled.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Keep system package set very small.
  environment.systemPackages = [
    pkgs.git
    pkgs.neovim
  ];

  # Minimal Home Manager integration.
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.erwin = import ./home.nix;
  };

  # ---- Disabled / optional config kept in comments ----
  #boot.kernelPackages = pkgs.linuxPackages_latest;
  #
  #i18n.extraLocaleSettings = {
  #  LC_ADDRESS = "nl_NL.UTF-8";
  #  LC_IDENTIFICATION = "nl_NL.UTF-8";
  #  LC_MEASUREMENT = "nl_NL.UTF-8";
  #  LC_MONETARY = "nl_NL.UTF-8";
  #  LC_NAME = "nl_NL.UTF-8";
  #  LC_NUMERIC = "nl_NL.UTF-8";
  #  LC_PAPER = "nl_NL.UTF-8";
  #  LC_TELEPHONE = "nl_NL.UTF-8";
  #  LC_TIME = "nl_NL.UTF-8";
  #};
  #
  #services.xserver.enable = true;
  #services.displayManager.sddm.enable = true;
  #services.desktopManager.plasma6.enable = true;
  #environment.etc."xdg/kdeglobals".text = ''
  #  [General]
  #  ColorScheme=BreezeDark
  #
  #  [KDE]
  #  LookAndFeelPackage=org.kde.breezedark.desktop
  #'';
  #
  #services.xserver.xkb = {
  #  layout = "us";
  #  variant = "intl";
  #};
  #
  #console.keyMap = "us-acentos";
  #services.printing.enable = true;
  #
  #hardware.enableAllFirmware = true;
  #hardware.firmware = [ pkgs.sof-firmware ];
  #boot.extraModprobeConfig = ''
  #  options snd-intel-dspcfg dsp_driver=1
  #'';
  #services.pulseaudio.enable = false;
  #security.rtkit.enable = true;
  #services.pipewire = {
  #  enable = true;
  #  alsa.enable = true;
  #  alsa.support32Bit = true;
  #  pulse.enable = true;
  #  wireplumber.enable = true;
  #};
  #
  #programs.firefox = {
  #  enable = true;
  #  policies = { };
  #};
  #
  #programs.nix-ld.enable = true;
  #nixpkgs.config.allowUnfree = true;
  #virtualisation.docker.enable = true;
  #environment.sessionVariables = {
  #  JAVA_HOME = "${pkgs.jdk25}";
  #};
  #programs.ssh.startAgent = true;

  system.stateVersion = "25.11";
}
