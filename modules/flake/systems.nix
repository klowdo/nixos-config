{lib, ...}: let
  keyedModule = lib.mkOptionType {
    name = "keyed-module";
    description = "module with a stable key derived from its option path";
    check = x: builtins.isAttrs x || builtins.isFunction x || builtins.isPath x;
    merge = loc: defs: {
      key = lib.showOption loc;
      _file = (builtins.head defs).file;
      imports = map (d: lib.setDefaultModuleLocation d.file d.value) defs;
    };
  };
in {
  options.flake.modules = lib.mkOption {
    type = lib.types.lazyAttrsOf (lib.types.lazyAttrsOf keyedModule);
    default = {};
    description = "Aspects published by the flake, grouped by module class.";
  };

  options.flake.homeConfigurations = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = {};
    description = "Standalone Home Manager configurations.";
  };

  config.systems = ["x86_64-linux"];
}
