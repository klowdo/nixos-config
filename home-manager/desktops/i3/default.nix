{pkgs, ...}:{
  xsession.windowManager.i3 = {
    enable = true;
     package = pkgs.i3-gaps;

    config = {
       modifier = "Mod4";
      gaps = {
        inner = 10;
        outer = 5;
      };

      bars = [
        {
          position = "top";
          statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-top.toml";
        }
      ];
    };
  };

  programs.i3status-rust = {
    enable = true;
    bars = {
      top = {
        blocks = [
         {
           block = "time";
           interval = 60;
           format = "%a %d/%m %k:%M %p";
         }
       ];
      };
    };
  };
  }
