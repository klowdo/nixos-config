# Official Anthropic plugins
# Format: "plugin-name@marketplace-name"
{lib, ...}: {
  enabledPlugins = {
    # Code review and quality
    "code-review@claude-plugins-official" = {
      enabled = true;
      description = "Comprehensive code review capabilities";
    };

    "code-simplifier@claude-plugins-official" = {
      enabled = true;
      description = "Simplify and refactor complex code";
    };

    # Security
    "security-guidance@claude-plugins-official" = {
      enabled = true;
      description = "Security best practices and vulnerability detection";
    };
  };
}
