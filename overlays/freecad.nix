# nix-update: freecad --version-regex '^\d+\.\d+\.\d+$'
final: prev: {
  freecad = prev.freecad.overrideAttrs (oldAttrs: {
    version = "1.1.0";
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
