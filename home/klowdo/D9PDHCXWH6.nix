{
  lib,
  pkgs,
  ...
}: let
  azureDevops = pkgs.azure-cli-extensions.azure-devops.overrideAttrs (old: {
    propagatedBuildInputs = (old.propagatedBuildInputs or []) ++ [pkgs.python3Packages.keyring];
  });
in {
  imports = [
    ./home.nix
    ./dotfiles/git.nix
    ../features/cli
    ../features/development
    ../features/communication
    ../features/desktop
    ../features/desktop/yabai
    ../common
  ];

  userConfig.username = lib.mkForce "FSVENS28";

  home.packages = [
    (pkgs.azure-cli.withExtensions [azureDevops])
    pkgs.azdo-tui
    pkgs.neovim
    pkgs.nh
    pkgs.unstable.tuicr
  ];
  programs.mise = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.ghostty = {
    enable = true;
    package = null; # Installed by Homebrew.
    enableZshIntegration = false; # Ghostty already injects its own shell integration.
    settings = {
      keybind = ["global:alt+o=toggle_quick_terminal"];
      quick-terminal-position = "center";
      quick-terminal-size = "70%,70%";
      quick-terminal-space-behavior = "move";
      quick-terminal-autohide = false;
    };
  };
  programs.gh-dash.settings.keybindings.prs = lib.mkAfter [
    {
      key = "T";
      name = "review in tuicr";
      command = "${lib.getExe pkgs.unstable.tuicr} pr {{.RepoName}}#{{.PrNumber}}";
    }
  ];
  xdg.configFile."tuicr/config.toml".text = ''
    editor = "${lib.getExe pkgs.neovim}"
  '';
  home.file.".claude/skills/nix-darwin".source = ../features/cli/claude/skills/nix-darwin;

  features = {
    cli = {
      zsh.enable = true;
      fzf.enable = true;
      fastfetch.enable = true;
      yazi.enable = true;
      tmux.enable = true;
      herdr.enable = true;
      worktrunk.enable = true;
      sesh.enable = true;
      gh.enable = true;
      ssh.enable = true;
      tools.enable = true;
      archives.enable = true;
    };

    communication.slack.enable = true;

    development.copilot-cli.enable = true;
    development.opencode.enable = true;

    desktop.yabai.enable = true;
  };
}
