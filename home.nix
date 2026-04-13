{ ... }:
{
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    autocd = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
  };


  programs.git = {
    enable = true;
    settings.user.name = "Erwin Olie";
  };

  programs.neovim.enable = true;
}
