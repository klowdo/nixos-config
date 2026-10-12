{...}: {
  flake.modules.homeManager.teams = {pkgs, ...}: {
    home.packages = with pkgs; [
      teams-for-linux
      libfido2
    ];

    xdg.configFile."teams-for-linux/config.json".text = builtins.toJSON {
      auth.webauthn.enabled = true;
    };
  };
}
