{inputs}: final: prev: {
  neovim = inputs.kixvim.packages.${prev.stdenv.hostPlatform.system}.default;
}
