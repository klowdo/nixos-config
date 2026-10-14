{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.gh;
in {
  options.features.cli.gh.enable = mkEnableOption "enable github (gh) cli tool";

  config = mkIf cfg.enable {
    home.packages = [pkgs.diffnav];

    programs.gh = {
      enable = true;
      gitCredentialHelper.enable = false;
      extensions = [pkgs.gh-enhance];
      settings = {
        git_protocol = "https";
        aliases.co = "pr checkout";
      };
    };

    programs.gh-dash = {
      enable = true;
      settings = {
        pager.diff = "diffnav";
        prSections = [
          {
            title = "Mine";
            filters = "is:open author:@me";
          }
          {
            title = "Review requested";
            filters = "is:open review-requested:@me";
          }
          {
            title = "Involved";
            filters = "is:open involves:@me -author:@me";
          }
        ];
        issuesSections = [
          {
            title = "Mine";
            filters = "is:open author:@me";
          }
          {
            title = "Assigned";
            filters = "is:open assignee:@me";
          }
        ];
        keybindings.prs = [
          {
            key = "E";
            name = "enhance";
            command = "gh enhance -R {{.RepoName}} {{.PrNumber}}";
          }
        ];
      };
    };
  };
}
