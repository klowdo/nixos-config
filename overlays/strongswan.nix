final: prev: {
  strongswan = prev.strongswan.overrideAttrs (oldAttrs: {
    configureFlags =
      oldAttrs.configureFlags
      ++ [
        "--enable-bypass-lan"
      ];
  });
}
