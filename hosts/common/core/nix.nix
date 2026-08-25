{...}: {
  nix.settings = {
    extra-substituters = [
      "https://klowdo.cachix.org"
    ];
    extra-trusted-substituters = [
      "https://klowdo.cachix.org"
    ];
    extra-trusted-public-keys = [
      "klowdo.cachix.org-1:m9fa/ozb0xWATsMwp96qj/0pOIcaunR1Z3v8+nGPQhM="
    ];
  };
}
