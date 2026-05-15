{ config, pkgs, ... }:

{
  home.username = "erwin";
  home.homeDirectory = "/home/erwin";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  programs.plasma = {
    enable = true;
    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      theme = "breeze-dark";
      colorScheme = "BreezeDark";
    };
  };
}
