{inputs, ...}: {
  additions = final: _prev: import ../pkgs {pkgs = final;};

  neovim = import ./neovim.nix {inherit inputs;};
  pulseaudio-dlna = import ./pulseaudio-dlna.nix;
  solaar = import ./solaar.nix;
  strongswan = import ./strongswan.nix;
  dotnet-combined = import ./dotnet-combined.nix;
  claude-code = import ./claude-code.nix {inherit inputs;};

  jetbrains-goland = import ./jetbrains-goland.nix;
  jetbrains-rider = import ./jetbrains-rider.nix;
  jetbrains-datagrip = import ./jetbrains-datagrip.nix;

  hyprnix = final: _prev: let
    hyprnixPkgs = inputs.hyprnix.packages.${final.stdenv.hostPlatform.system};
  in {
    hyprland = hyprnixPkgs.hyprland;
    hyprlock = hyprnixPkgs.hyprlock;
    hypridle = hyprnixPkgs.hypridle;
    hyprpaper = hyprnixPkgs.hyprpaper;
    hyprpicker = hyprnixPkgs.hyprpicker;
    hyprcursor = hyprnixPkgs.hyprcursor;
    hyprpolkitagent = hyprnixPkgs.hyprpolkitagent;
    hyprland-protocols = hyprnixPkgs.hyprland-protocols;
    xdg-desktop-portal-hyprland = hyprnixPkgs.xdg-desktop-portal-hyprland;
  };

  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
  };

  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      inherit (final.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
  };
}
