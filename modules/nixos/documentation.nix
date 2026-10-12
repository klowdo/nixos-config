# Disable NixOS documentation generation to avoid warnings from upstream modules
# that use builtins.derivation improperly when generating options.json
{
  flake.modules.nixos.documentation = {
    documentation.nixos.enable = false;
  };
}
