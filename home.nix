{ ... }:
{
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    autocd = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    initExtra = ''
      bindkey "^[[1;5D" backward-word
      bindkey "^[[1;5C" forward-word
    '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.git = {
    enable = true;
    settings.user.name = "Erwin Olie";
  };

  programs.neovim.enable = true;
}
