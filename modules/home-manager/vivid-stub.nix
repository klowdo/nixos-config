{lib, ...}: {
  # Stub module to prevent stylix from failing when trying to configure vivid
  # Home Manager 25.11 doesn't have programs.vivid yet, but Stylix tries to configure it
  options.programs.vivid = lib.mkOption {
    type = lib.types.attrs;
    default = {};
    description = "Stub for vivid program (not yet in Home Manager)";
  };
}
