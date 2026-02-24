{...}: {
  nix.settings = {
    extra-substituters = [
      "https://klowdo.cachix.org"
    ];
    extra-trusted-substituters = [
      "https://klowdo.cachix.org"
    ];
    extra-trusted-public-keys = [
      "klowdo.cachix.org-1:FY4Cq5DPh6QYyU2R2PGgCNdXbh7u6H3kRRpmydZbdXc="
    ];
  };
}
