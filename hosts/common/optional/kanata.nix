{
  services.kanata = {
    enable = true;
    keyboards.internal = {
      devices = ["/dev/input/by-path/platform-i8042-serio-0-event-kbd"];

      extraDefCfg = ''
        process-unmapped-keys yes
        concurrent-tap-hold yes
      '';

      config = ''
        (defvar
          tt 200
          ht 200
          left  (q w e r t a s d f g z x c v b)
          right (y u i o p h j k l ; n m , . /))

        (defsrc
          a s d f j k l ;)

        (defalias
          a    (tap-hold-release-keys $tt $ht a lsft $left)
          s    (tap-hold-release-keys $tt $ht s lctl $left)
          d    (tap-hold-release-keys $tt $ht d lalt $left)
          f    (tap-hold-release-keys $tt $ht f lmet $left)
          j    (tap-hold-release-keys $tt $ht j rctl $right)
          k    (tap-hold-release-keys $tt $ht k ralt $right)
          l    (tap-hold-release-keys $tt $ht l rmet $right)
          scln (tap-hold-release-keys $tt $ht ; rsft $right))

        (deflayer base
          @a @s @d @f @j @k @l @scln)
      '';
    };
  };
}
