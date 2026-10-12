{
  flake.modules.nixos.gnome-keyring = {pkgs, ...}: {
    services.gnome.gnome-keyring.enable = true;

    security.pam.services = {
      login.enableGnomeKeyring = true;
      passwd.enableGnomeKeyring = true;
    };

    environment.systemPackages = with pkgs; [
      seahorse
      gcr
      libsecret
    ];

    programs.ssh.startAgent = false;
    environment.variables = {
      SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/keyring/ssh";
    };
  };
}
