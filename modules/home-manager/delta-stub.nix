{lib, ...}: {
  # Stub module to prevent stylix from failing when trying to configure vivid
  # Home Manager 25.05 doesn't have programs.vivid yet, but Stylix tries to configure it
  options.programs.delta = lib.mkOption {
    type = lib.types.attrs;
    default = {};
    description = "Stub for delta program (not in Home Manager anymore)";
  };
}
