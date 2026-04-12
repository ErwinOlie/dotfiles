{ ... }:
{
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "Erwin Olie";
  };
}
