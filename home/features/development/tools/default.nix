{config, ...}: {
  imports = [
    ./rider.nix
    ./rustrover.nix
    ./libreoffice.nix
    ./goland.nix
    ./datagrip.nix
    ./junie.nix
  ];

  home.file.".ideavimrc".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.sessionVariables.NH_FLAKE}/home/features/development/tools/ideavimrc";
}
