# Claude Code Skills Configuration
# Manages skills from various sources including claude-cookbooks
{
  lib,
  inputs,
  ...
}: let
  # Helper to create a skill entry from a cookbook source
  mkCookbookSkill = name: path: {
    inherit name;
    source = "cookbook";
    sourcePath = "${inputs.claude-cookbooks}/${path}";
  };

  # Helper to create a skill entry from anthropic-skills
  mkAnthropicSkill = name: path: {
    inherit name;
    source = "anthropic";
    sourcePath = "${inputs.anthropic-skills}/${path}";
  };
in {
  # Commands from claude-cookbooks
  commands = {
    # GitHub operations
    review-issue = mkCookbookSkill "review-issue" "claude-code/commands/review-issue.md";

    # Notebook operations
    notebook-review = mkCookbookSkill "notebook-review" "claude-code/commands/notebook-review.md";

    # Validation
    model-check = mkCookbookSkill "model-check" "claude-code/commands/model-check.md";
    link-review = mkCookbookSkill "link-review" "claude-code/commands/link-review.md";
  };

  # Agents from claude-cookbooks
  agents = {
    code-reviewer = mkCookbookSkill "code-reviewer" "claude-code/agents/code-reviewer.md";
  };

  # Skills from anthropic-skills (if available)
  skills = lib.optionalAttrs (inputs ? anthropic-skills) {
    # Add skills as they become available in the repo
  };
}
