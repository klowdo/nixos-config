{lib}: {
  # use path relative to the root of the project
  relativeToRoot = lib.path.append ../.;

  # Scan a directory for .nix files and subdirectories
  scanPaths = path:
    builtins.map (f: (path + "/${f}")) (
      builtins.attrNames (
        lib.attrsets.filterAttrs
        (
          path: _type:
            (_type == "directory") # include directories
            || (
              (path != "default.nix") # ignore default.nix
              && (lib.strings.hasSuffix ".nix" path) # include .nix files
            )
        )
        (builtins.readDir path)
      )
    );

  # Filter groups to only those that exist on the system
  # Usage: extraGroups = ["wheel"] ++ lib.custom.ifTheyExist config ["docker" "libvirtd"];
  ifTheyExist = cfg: groups:
    builtins.filter (group: builtins.hasAttr group cfg.users.groups) groups;
}
