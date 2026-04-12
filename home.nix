{ ... }:
{
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  services.ssh-agent.enable = true;

  programs.zsh = {
    enable = true;
    autocd = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.git = {
    enable = true;
    settings.user.name = "Erwin Olie";
  };

  programs.ssh = {
    enable = true;
    matchBlocks."*" = {
      addKeysToAgent = "yes";
    };
  };

  programs.neovim.enable = true;
}
