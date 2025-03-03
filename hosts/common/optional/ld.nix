{pkgs, ...}: {
  # for aspire dotnet
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    mpifileutils
    icu # for aspire 9.1 localization
  ];

  environment.systemPackages = with pkgs; [
    icu # for aspire 9.1 localization
  ];
}
