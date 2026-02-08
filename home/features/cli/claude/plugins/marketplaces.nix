# Claude Code Plugin Marketplaces
# Defines sources for plugin discovery and installation
#
# IMPORTANT: Each key MUST match the `name` field in the repo's
# .claude-plugin/marketplace.json for plugin references to work.
{
  lib,
  inputs,
  ...
}: {
  # Official Anthropic plugins
  claude-plugins-official = {
    source = {
      type = "github";
      url = "github:anthropics/claude-plugins-official";
    };
    flakeInput = inputs.claude-plugins-official or null;
    description = "Official Anthropic curated plugins";
  };

  # Anthropic skills
  anthropic-agent-skills = {
    source = {
      type = "github";
      url = "github:anthropics/skills";
    };
    flakeInput = inputs.anthropic-skills or null;
    description = "Official Anthropic agent skills";
  };

  # Community marketplaces
  claude-skills = {
    source = {
      type = "github";
      url = "github:secondsky/claude-skills";
    };
    flakeInput = inputs.claude-skills or null;
    description = "174+ production-ready skills marketplace";
  };

  superpowers-marketplace = {
    source = {
      type = "github";
      url = "github:obra/superpowers-marketplace";
    };
    flakeInput = inputs.superpowers-marketplace or null;
    description = "Comprehensive software development workflows";
  };

  claude-code-workflows = {
    source = {
      type = "github";
      url = "github:wshobson/agents";
    };
    flakeInput = inputs.claude-code-workflows or null;
    description = "Backend and testing workflows";
  };

  # Time tracking
  claude-code-wakatime = {
    source = {
      type = "github";
      url = "github:wakatime/claude-code-wakatime";
    };
    flakeInput = inputs.claude-code-wakatime or null;
    description = "WakaTime time tracking integration for Claude Code";
  };
}
