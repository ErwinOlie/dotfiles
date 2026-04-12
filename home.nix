{ pkgs, ... }:
{
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  services.ssh-agent.enable = true;

  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    matchBlocks = {
      github = {
        host = "github.com";
        identityFile = "~/.ssh/id_github";
      };
    };
  };

  systemd.user.services.ssh-add-all-keys = {
    Unit = {
      Description = "Add all private SSH keys to agent";
      After = [ "ssh-agent.service" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -lc 'shopt -s nullglob; for key in \"$HOME\"/.ssh/*; do [[ -f \"$key\" ]] || continue; case \"$(basename \"$key\")\" in *.pub|known_hosts|known_hosts.old|config|authorized_keys|*.crt) continue;; esac; ${pkgs.openssh}/bin/ssh-add \"$key\" >/dev/null 2>&1 || true; done'";
    };
    Install.WantedBy = [ "default.target" ];
  };

  programs.git = {
    enable = true;
    settings.user.name = "Erwin Olie";
  };
}
