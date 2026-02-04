# Community plugins from various marketplaces
# Format: "plugin-name@marketplace-name"
{lib, ...}: {
  enabledPlugins = {
    # From claude-skills marketplace (secondsky)
    "nix-helper@claude-skills" = {
      enabled = true;
      description = "NixOS and Nix flake assistance";
    };

    "git-workflow@claude-skills" = {
      enabled = true;
      description = "Advanced git operations and workflows";
    };

    # From superpowers-marketplace
    "thoughtful-coder@superpowers-marketplace" = {
      enabled = true;
      description = "Thoughtful software development workflow";
    };

    "test-driven-dev@superpowers-marketplace" = {
      enabled = true;
      description = "TDD workflow support";
    };
  };
}
