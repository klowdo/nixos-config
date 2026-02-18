{
  config,
  options,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.hyprland;
  hasStylix = options ? stylix;
  yamlFormat = pkgs.formats.yaml {};

  styleSheet = with config.lib.stylix.colors;
    pkgs.writeText "hyprland-share-picker-style.css" ''
      * {
        all: unset;
        font-family: ${config.stylix.fonts.monospace.name};
        color: #${base05};
        font-weight: bold;
        font-size: 16px;
      }

      .window {
        border-radius: 5px;
        background-color: #${base00};
        border: solid 2px #${base02};
        margin: 2px;
      }

      tabs {
        padding: 0.5rem 1rem;
      }

      tabs > tab {
        margin-right: 1rem;
      }

      .tab-label {
        color: #${base04};
        transition: all 0.2s ease;
      }

      tabs > tab:checked > .tab-label,
      tabs > tab:active > .tab-label {
        text-decoration: underline currentColor;
        color: #${base05};
      }

      tabs > tab:focus > .tab-label {
        color: #${base05};
      }

      .page {
        padding: 1rem;
      }

      .image-label {
        font-size: 12px;
        padding: 0.25rem;
      }

      flowboxchild > .card, button > .card {
        transition: all 0.2s ease;
        border: solid 2px transparent;
        border-color: #${base01};
        border-radius: 5px;
        background-color: #${base01};
        padding: 5px;
      }

      flowboxchild:active > .card,
      flowboxchild:selected > .card,
      button:active > .card,
      button:selected > .card,
      button:focus > .card {
        border: solid 2px #${base0D};
      }

      .image {
        border-radius: 5px;
      }

      .region-button {
        padding: 0.5rem 1rem;
        border-radius: 5px;
        background-color: #${base0D};
        color: #${base00};
        transition: all 0.2s ease;
      }

      .region-button:not(:disabled):hover,
      .region-button:not(:disabled):focus {
        background-color: #${base0C};
      }

      .region-button:disabled {
        background-color: #${base03};
        color: #${base02};
      }
    '';
in {
  config = mkIf (cfg.enable && hasStylix) {
    home.packages = [
      pkgs.hyprland-preview-share-picker
      pkgs.slurp
    ];

    xdg.configFile."hypr/xdph.conf".text = ''
      screencopy {
        allow_token_by_default = true
        custom_picker_binary = ${pkgs.hyprland-preview-share-picker}/bin/hyprland-preview-share-picker
      }
    '';

    xdg.configFile."hyprland-preview-share-picker/config.yaml".source = yamlFormat.generate "hyprland-share-picker-config.yaml" {
      window = {
        width = 1000;
        height = 500;
      };

      image = {
        resize_to = 200;
        display_at = 150;
      };

      layout = {
        cards_per_row = 4;
        spacing = 10;
        click_requirement = "single";
      };

      region_selector = "slurp";
      hide_token_restore = true;

      stylesheets = [
        "${styleSheet}"
      ];
    };
  };
}
