_final: prev: {
  vesktop = prev.vesktop.overrideAttrs (oldAttrs: {
    postFixup =
      (oldAttrs.postFixup or "")
      + ''
        wrapProgram $out/bin/vesktop \
          --add-flags "--enable-features=WebRTCPipeWireCapturer"
      '';
  });
}
