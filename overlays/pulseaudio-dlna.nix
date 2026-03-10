final: prev: {
  pulseaudio-dlna = prev.pulseaudio-dlna.overrideAttrs (oldAttrs: {
    buildInputs =
      (oldAttrs.buildInputs or [])
      ++ [
        prev.gobject-introspection
      ];
    nativeBuildInputs =
      (oldAttrs.nativeBuildInputs or [])
      ++ [
        prev.wrapGAppsHook3
        prev.gobject-introspection
      ];
  });
}
