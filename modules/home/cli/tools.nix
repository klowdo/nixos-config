{...}: {
  flake.modules.homeManager.tools = {pkgs, ...}: {
    home.packages = with pkgs; [
      coreutils
      fd
      htop
      httpie
      jq
      procs
      ripgrep
      tldr
      zip
      unp
      wishlist
      unstable.witr
      unstable.isd
    ];
  };
}
