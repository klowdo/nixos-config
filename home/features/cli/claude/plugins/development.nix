# Development-focused plugins
# Format: "plugin-name@marketplace-name"
{lib, ...}: {
  enabledPlugins = {
    # Git operations
    "commit-commands@claude-plugins-official" = {
      enabled = true;
      description = "Enhanced git commit workflows";
    };

    "pr-review-toolkit@claude-plugins-official" = {
      enabled = true;
      description = "Pull request review automation";
    };

    # Feature development
    "feature-dev@claude-plugins-official" = {
      enabled = true;
      description = "Feature development workflow";
    };

    # Backend workflows
    "backend-workflow@claude-code-workflows" = {
      enabled = true;
      description = "Backend development patterns";
    };

    "testing-workflow@claude-code-workflows" = {
      enabled = true;
      description = "Testing best practices";
    };
  };
}
