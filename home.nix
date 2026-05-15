{ ... }:
{
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  # Keep Home Manager minimal.
  programs.zsh.enable = true;
  programs.git.enable = true;

  # ---- Disabled / optional config kept in comments ----
  #programs.zsh = {
  #  enable = true;
  #  autocd = false;
  #  enableCompletion = true;
  #  syntaxHighlighting.enable = true;
  #  autosuggestion.enable = true;
  #  history.share = true;
  #  initContent = ''
  #    setopt INC_APPEND_HISTORY
  #    bindkey "^[[1;5D" backward-word
  #    bindkey "^[[1;5C" forward-word
  #  '';
  #};
  #
  #programs.git = {
  #  enable = true;
  #  settings.user.name = "Erwin Olie";
  #};
  #
  #services.ssh-agent.enable = true;
  #programs.neovim.enable = true;
}
