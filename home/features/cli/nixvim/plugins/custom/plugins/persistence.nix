{
  # https://nix-community.github.io/nixvim/plugins/toggleterm/index.html
  programs.nixvim = {
    plugins.persistence = {
      enable = true;
      # enableTelescope = true;
      extraOptions = {
        need = 1;
        branch = false;
      };
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>qs";
        action = "<CMD>lua require(\"persistence\").load()<CR>";
        options = {
          desc = "load the session for the current directory";
        };
      }

      {
        mode = "n";
        key = "<leader>qS";
        action = "<CMD>lua require(\"persistence\").select()<CR>";
        options = {
          desc = "select a session to load";
        };
      }
      {
        mode = "n";
        key = "<leader>ql";
        action = "<CMD>lua require(\"persistence\").load({ last = true })<CR>";
        options = {
          desc = "load the last session";
        };
      }
      {
        mode = "n";
        key = "<leader>qd";
        action = ":lua require(\"persistence\").stop()";
        options = {
          desc = "stop Persistence => session won't be saved on exit";
        };
      }
    ];
  };
}
