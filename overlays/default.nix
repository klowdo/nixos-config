{inputs, ...}: {
  additions = final: _prev: import ../pkgs {pkgs = final;};

  neovim = import ./neovim.nix {inherit inputs;};
  pulseaudio-dlna = import ./pulseaudio-dlna.nix;
  solaar = import ./solaar.nix;
  strongswan = import ./strongswan.nix;
  dotnet-combined = import ./dotnet-combined.nix;
  claude-code = import ./claude-code.nix {inherit inputs;};
  # freecad = import ./freecad.nix;
  sesh = import ./sesh.nix;

  jetbrains-goland = import ./jetbrains-goland.nix;
  jetbrains-rider = import ./jetbrains-rider.nix;
  jetbrains-datagrip = import ./jetbrains-datagrip.nix;

  hyprnix = _final: prev:
    if prev ? stdenv
    then inputs.hyprnix.packages.${prev.stdenv.hostPlatform.system} or {}
    else {};

  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final.stdenv.hostPlatform) system;
      config.allowUnfree = true;
      overlays = [
        (import ./worktrunk.nix)
      ];
    };
  };

  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      inherit (final.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
  };
}
