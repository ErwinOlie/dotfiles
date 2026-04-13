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
    history = {
      size = 50000;
      share = true;
    };
    initContent = ''
      bindkey "^[[1;5D" backward-word
      bindkey "^[[1;5C" forward-word
    '';
  };


  programs.git = {
    enable = true;
    settings.user.name = "Erwin Olie";
  };

  services.ssh-agent.enable = true;

  programs.neovim.enable = true;
}
