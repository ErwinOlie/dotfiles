{ config, pkgs, ... }:

{
  home.stateVersion = "25.11";

  programs.git = {
    enable = true;
    settings.user.name = "Erwin Olie";
  };

  programs.plasma = {
    enable = true;
    workspace.colorScheme = "BreezeDark";
  };
}
