{ config, pkgs, ... }:

{
  home.stateVersion = "25.11";

  programs.plasma = {
    enable = true;
    workspace.colorScheme = "BreezeDark";
  };
}
