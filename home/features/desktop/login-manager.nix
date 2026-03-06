{lib, ...}: {
  options.features.desktop.loginManager.enable =
    lib.mkEnableOption "external login manager handles session startup";
}
