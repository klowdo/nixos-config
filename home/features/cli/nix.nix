{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.nix-index-database.homeModules.nix-index
  ];
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
  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.nix-index-database.comma.enable = true;
  # programs.nix-your-shell.enable = true;
}
