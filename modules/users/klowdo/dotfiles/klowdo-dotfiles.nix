{...}: {
  flake.modules.homeManager.klowdo-dotfiles = {
    imports = [
      ./_audio-select.nix
      ./_git.nix
    ];
  };
}
