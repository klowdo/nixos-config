{...}: {
  flake.modules.homeManager.taskwarrior = {pkgs, ...}: {
    programs.taskwarrior = {
      enable = true;
      package = pkgs.taskwarrior3;
    };
    home.packages = with pkgs; [
      vit
      taskwarrior-tui
      tasksh
    ];
  };
}
