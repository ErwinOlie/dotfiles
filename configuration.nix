{ config, pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/fa415e11-8e0e-4159-a0ed-ae626973fbe9";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/DD03-9459";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  time.timeZone = "Europe/Amsterdam";

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;
  networking.networkmanager.enable = true;

  users.users.erwin = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  programs.ssh.startAgent = true;
  programs.firefox = {
    enable = true;
    policies = {
      DontCheckDefaultBrowser = true;

      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisableFirefoxAccounts = true;

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
    };
  };
  environment.systemPackages = with pkgs; [
    git
    gimp
    slack
    bruno
    signal-desktop
    simple-scan
    jdk25
    anki
    jetbrains.idea
  ];

  system.stateVersion = "25.11";
}
