{lib, ...}: {
  # Stub module to prevent stylix from failing when trying to configure vivid
  options.programs.delta = lib.mkOption {
  # Home Manager 25.11 doesn't have programs.vivid yet, but Stylix tries to configure it

    type = lib.types.attrs;
    default = {};
    description = "Stub for delta program (not in Home Manager anymore)";
  };
}
