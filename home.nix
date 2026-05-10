{ config, pkgs, ... }:
let
  dotfilesRepo = "${config.home.homeDirectory}/dotfiles";
in
{
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    autocd = false;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
    history = {
      share = true;
    };
    initContent = ''
      setopt INC_APPEND_HISTORY
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

  home.packages = with pkgs; [
    libnotify
    git
  ];

  home.file.".local/bin/dotfiles-check-update" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      REPO_PATH="${dotfilesRepo}"
      REMOTE="origin"
      BRANCH="main"

      if ! git -C "$REPO_PATH" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        exit 0
      fi

      git -C "$REPO_PATH" fetch "$REMOTE" "$BRANCH" --quiet || exit 0

      LOCAL_COMMIT="$(git -C "$REPO_PATH" rev-parse HEAD)"
      REMOTE_COMMIT="$(git -C "$REPO_PATH" rev-parse "$REMOTE/$BRANCH")"

      if [[ "$LOCAL_COMMIT" == "$REMOTE_COMMIT" ]]; then
        exit 0
      fi

      ${pkgs.libnotify}/bin/notify-send \
        "Dotfiles update beschikbaar" \
        "Klik om ErwinOlie/dotfiles bij te werken en uit te rollen" \
        --app-name="dotfiles-updater" \
        --icon=software-update-available \
        --action="update=Update nu" \
        --expire-time=15000 \
      | {
          read -r action || true
          if [[ "$action" == "update" ]]; then
            "${config.home.homeDirectory}/.local/bin/dotfiles-apply-update"
          fi
        }
    '';
  };

  home.file.".local/bin/dotfiles-apply-update" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      REPO_PATH="${dotfilesRepo}"

      if ! git -C "$REPO_PATH" pull --ff-only; then
        ${pkgs.libnotify}/bin/notify-send "Dotfiles update mislukt" "Git pull is mislukt." --app-name="dotfiles-updater"
        exit 1
      fi

      if command -v nixos-rebuild >/dev/null 2>&1; then
        if sudo nixos-rebuild switch --flake "$REPO_PATH"; then
          ${pkgs.libnotify}/bin/notify-send "Dotfiles bijgewerkt" "NixOS configuratie is uitgerold." --app-name="dotfiles-updater"
          exit 0
        fi
      fi

      if command -v home-manager >/dev/null 2>&1; then
        if home-manager switch --flake "$REPO_PATH"; then
          ${pkgs.libnotify}/bin/notify-send "Dotfiles bijgewerkt" "Home Manager configuratie is uitgerold." --app-name="dotfiles-updater"
          exit 0
        fi
      fi

      ${pkgs.libnotify}/bin/notify-send "Dotfiles opgehaald" "Geen deployment command uitgevoerd." --app-name="dotfiles-updater"
    '';
  };

  systemd.user.services.dotfiles-update-check = {
    Unit = {
      Description = "Check for updates in ErwinOlie/dotfiles";
      After = [ "network-online.target" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${config.home.homeDirectory}/.local/bin/dotfiles-check-update";
    };
  };

  systemd.user.timers.dotfiles-update-check = {
    Unit.Description = "Periodieke check voor ErwinOlie/dotfiles updates";

    Timer = {
      OnBootSec = "1m";
      OnUnitActiveSec = "1m";
      Unit = "dotfiles-update-check.service";
    };

    Install.WantedBy = [ "timers.target" ];
  };
}
