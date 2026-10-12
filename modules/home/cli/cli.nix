{...}: {
  flake.modules.homeManager.cli = {pkgs, ...}: {
    programs = {
      zoxide = {
        enable = true;
        enableZshIntegration = true;
        options = [
          "--cmd cd"
        ];
      };
      eza = {
        enable = true;
        enableZshIntegration = true;
        enableBashIntegration = true;
        extraOptions = ["-l" "--icons" "--git" "-a"];
      };
      atuin = {
        enable = true;
        enableZshIntegration = true;
        settings = {
          auto_sync = false;
          show_preview = false;
        };
        flags = ["--disable-up-arrow"];
      };
      bat = {
        enable = true;
        extraPackages = with pkgs.bat-extras; [batman];
      };
      bash.enable = true;
      btop.enable = true;
      zsh.shellAliases.vimdiff = "nvim -d";
    };
  };
}
