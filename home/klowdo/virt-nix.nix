{ config, ... }: {
  imports = [
    ./home.nix
    ../features/cli
    ../common
  ];

  features = {
    cli = {
      zsh.enable = true;
    };
  };
}

