{...}: {
  nix.settings = {
    extra-substituters = [
      "https://klowdo.cachix.org"
      "https://hyprland.cachix.org"
    ];
    extra-trusted-substituters = [
      "https://klowdo.cachix.org"
      "https://hyprland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "klowdo.cachix.org-1:m9fa/ozb0xWATsMwp96qj/0pOIcaunR1Z3v8+nGPQhM="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };
}
