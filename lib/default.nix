{lib}: {
  # use path relative to the root of the project
  relativeToRoot = lib.path.append ../.;

  # Filter groups to only those that exist on the system
  # Usage: extraGroups = ["wheel"] ++ lib.custom.ifTheyExist config ["docker" "libvirtd"];
  ifTheyExist = cfg: groups:
    builtins.filter (group: builtins.hasAttr group cfg.users.groups) groups;
}
