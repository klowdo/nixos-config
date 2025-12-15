{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs;
    [
      nixfmt-rfc-style
      nixpkgs-fmt
      nixd
      deadnix
      statix
      nurl
    ]
    ++ (with inputs.nsearch.packages.${pkgs.stdenv.hostPlatform.system}; [nsearch nrun nshell]);
  programs.nix-index.enable = true;
  # programs.nix-index-database.comma.enable = true;
  # programs.nix-your-shell.enable = true;
}
