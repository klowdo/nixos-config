# Claude Code plugins configuration
# Imports and merges all plugin category modules
{
  lib,
  inputs,
  ...
}: let
  # Import plugin category modules
  marketplaces = import ./marketplaces.nix {inherit lib inputs;};
  official = import ./official.nix {inherit lib;};
  community = import ./community.nix {inherit lib;};
  development = import ./development.nix {inherit lib;};
in {
  inherit marketplaces;

  # Merge all enabled plugins from categories
  enabledPlugins =
    official.enabledPlugins
    // community.enabledPlugins
    // development.enabledPlugins;
}
