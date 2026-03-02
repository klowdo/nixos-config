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
      "klowdo.cachix.org-1:FY4Cq5DPh6QYyU2R2PGgCNdXbh7u6H3kRRpmydZbdXc="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };
}
