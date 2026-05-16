{ config, pkgs, ... }:

{
  home.stateVersion = "25.11";

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
        identitiesOnly = true;
        identityFile = [
          "~/.ssh/id_github"
        ];
      };
    };
  };

  programs.git = {
    enable = true;
    settings.user.name = "Erwin Olie";
  };

  programs.plasma = {
    enable = true;
    workspace.colorScheme = "BreezeDark";
  };
}
