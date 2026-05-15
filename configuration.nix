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

  services.displayManager.sddm.enable = true;
  services.desktopManage.rplasma6.enable = true;

  users.users.erwin = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  system.stateVersion = "25.11";
}
