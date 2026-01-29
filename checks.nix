{
  inputs,
  pkgs,
  ...
}: {
  pre-commit-check = inputs.pre-commit-hooks.lib.${pkgs.stdenv.hostPlatform.system}.run {
    src = ./.;
    package = pkgs.prek;
    hooks = {
      # General
      check-added-large-files.enable = true;
      check-case-conflicts.enable = true;
      check-executables-have-shebangs.enable = true;
      check-merge-conflicts.enable = true;
      detect-private-keys.enable = true;
      fix-byte-order-marker.enable = true;
      mixed-line-endings.enable = true;
      trim-trailing-whitespace.enable = true;
      end-of-file-fixer.enable = true;

      # Nix
      alejandra = {
        enable = true;
        settings.check = false;
      };
      deadnix = {
        enable = true;
        settings = {
          edit = true;
          noLambdaArg = true;
        };
      };

      # Shell
      shfmt.enable = true;
      shellcheck.enable = true;
    };
  };
}
