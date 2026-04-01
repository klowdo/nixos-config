# nix-update: freecad
final: prev: {
  freecad = prev.freecad.overrideAttrs (oldAttrs: {
    version = "weekly-2026.04.01";
    src = prev.fetchFromGitHub {
      owner = "FreeCAD";
      repo = "FreeCAD";
      tag = "1.1.0";
      hash = "sha256-knyc4Ts9dd12i0SsVDeoCs37jrMxekc07KBf3wJvNgk=";
      fetchSubmodules = true;
    };
    buildInputs = oldAttrs.buildInputs ++ [final.mpi];
    patches = [
      (builtins.head oldAttrs.patches)
    ];
    postPatch = ''
      substituteInPlace src/Mod/Fem/femmesh/gmshtools.py \
        --replace-fail 'self.gmsh_bin = ""' 'self.gmsh_bin = "${prev.lib.getExe final.gmsh}"'
    '';
  });
}
