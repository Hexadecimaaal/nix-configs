{
  programs.lesspipe.enable = true;
  home.sessionVariables = {
    LESS = "--mouse -FRXMQi";
    SYSTEMD_LESS = "--mouse -FRXMKQi";
  };
  programs.less = {
    enable = true;
    keys = ''
      # [2002-01-28, 19.22-19.56] Zrajm C Akfohg
      # For description of commands etc. see lesskey(1),

      #command

          # special remaps (for Zrajm)
          \240    noaction \40#            # nbsp             is remapped to space
          \255    noaction -#              # hyphen (dec 173) is remapped to dash
          # ä       noaction /\^ *\\b\e[D\eOD# ä search for word at beginning of line
          # å       noaction /\\b\\b\e[D\eOD## ä search for word

          # syntax: <string> <action> [extra-string] <newline>
          \t      undo-hilite             # Tab      (enable/disable search hilite)
          \40     forw-screen             # Space
          \e[6~   forw-screen             # PageDown

          # arrows (up / down / right / left)
          \e[A    back-line
          \e[B    forw-line
          \e[C    right-scroll
          \e[D    left-scroll

          # shiftarrows (up / down / right / left)
          \e[2A   goto-line
          \e[2B   goto-end
          \e[2C   invalid
          \e[2D   invalid

          # ctrl-arrows (up / down / right / left)
          \e[5A   back-screen
          \e[5B   forw-screen-force
          \e[5C   next-file
          \e[5D   prev-file


          # keypad (in application mode)
          \eOM    noaction ^M
          \eOj    noaction *
          \eOk    noaction +
          \eOm    noaction -
          \eOo    noaction /
          \eOp    noaction 0
          \eOq    noaction 1
          \eOr    noaction 2
          \eOs    noaction 3
          \eOt    noaction 4
          \eOu    noaction 5
          \eOv    noaction 6
          \eOw    noaction 7
          \eOx    noaction 8
          \eOy    noaction 9

          \e[4~   goto-end        # fix faulty End key
          \e[1~   goto-line       # fix faulty Home key


      #line-edit
          # (`digit' and `set-mark' cant be used here)

          # zrajm specials
          #      literal -#      # change all hyphen into minus
          #      literal \40#    # change all nbsp to space


          # move over character
          \eOA    up              # (application mode: up)
          \eOB    down            # (application mode: down)
          \eOC    right           # (application mode: right)
          \eOD    left            # (application mode: left)
          \e[A    up              # (default mode: up)
          \e[B    down            # (default mode: down)
          \e[C    right           # (default mode: right)
          \e[D    left            # (default mode: left)
          ^P      up              # (emacsstyle: CtrlP - previous)
          ^N      down            # (emacsstyle: CtrlN - next)
          ^F      right           # (emacsstyle: CtrlF - forward)
          ^B      left            # (emacsstyle: CtrlB - backward)

          # move over word
          \eO5C   word-right      # (application mode: Ctrlright)
          \eO5D   word-left       # (application mode: Ctrlleft)
          \e[5C   word-right      # (default mode: Ctrlright)
          \e[5D   word-left       # (default mode: Ctrlleft)
          \eb     word-left       # (emacsstyle: Escb)
          \eB     word-left       # (emacsstyle: EscB)
          \ef     word-right      # (emacsstyle: Escf)
          \eF     word-right      # (emacsstyle: EscF)

          # move to endofline
          \eO2C   end             # (application mode: ShiftLeft)
          \eO2D   home            # (application mode: ShiftRight)
          \e[2C   end             # (default mode: ShiftLeft)
          \e[2D   home            # (default mode: ShiftRight)
          ^A      home            # (emacsstyle: CtrlA)
          ^E      end             # (emacsstyle: CtrlE)
          \e[1~   home            # (terminal: Home)
          \e[4~   end             # (terminal: End)

          # delete character
          ^D      delete          # (?)
          \e[3~   delete          # (terminal)

          # delete word
          \ed     word-delete     # (emacsstyle: Esc-d)
          \eD     word-delete     # (emacsstyle: Esc-D)
          ^W      word-backspace  # (emacs style: CtrlW)
          \e^H    word-backspace  # (emacs style: Esc+Ctrl-H)
          \e^?    word-backspace  # Esc-Backspace  (faulty default for less)
          ^H      word-backspace  # CtrlBackspace (faulty default for less)

          # delete to part of line
          ^U      kill-line
          ^G      word-backspace ^W^W^W^W^W^W^W^W^W^W^W^W^W^W^W^W^W^W^W^W^W^W^W^W^W^W^W^W^W^W^W^W^W^W^W^W^W^W^W^W^W^W^W^W^W^W^W^W^W^W
          ^K      word-delete    \ed\ed\ed\ed\ed\ed\ed\ed\ed\ed\ed\ed\ed\ed\ed\ed\ed\ed\ed\ed\ed\ed\ed\ed\ed\ed\ed\ed\ed\ed\ed\ed\ed\ed\ed\ed\ed\ed\ed\ed\ed\ed\ed\ed\ed\ed\ed\ed\ed\ed

          # disabled keys
          \e[5~   insert #        # (Page Up)
          \e[6~   insert #        # (Page Down)


          # unmapped key (for experimenting)

          ^V      literal

          # keypad (in application mode)
          \eOM    literal ^M
          \eOj    literal *
          \eOk    literal +
          \eOm    literal -
          \eOo    literal /
          \eOp    literal 0
          \eOq    literal 1
          \eOr    literal 2
          \eOs    literal 3
          \eOt    literal 4
          \eOu    literal 5
          \eOv    literal 6
          \eOw    literal 7
          \eOx    literal 8
          \eOy    literal 9



      #env
      #
      # [20021003] Zrajm C Akfohg.
      #
      # I don't set my less(1) related environment variables here anymore. I do it in
      # my `~/.zshenv' file. If all variables are set in the shell, I can also change
      # them in the shell, this in comfortable, compared to changing them here and
      # rerunning `lesskey' each time I experiment with something.
      #
      # The settings I had here before I removed them was:
      #
      #LESS            = -RXQiz-2
      #LESSCHARDEF     = 8bcccbcc13bc4b95.33b.
      #LESSBINFMT      = *s\%o
      #JLESSKEYCHARSET = latin1
      #
      # These settings enable:
      #
      #    o Latin1 charset (Swedish characters ÅÄÖ).
      #    o ANSI graphics (LESSCHARDEF is used to convince less that textfiles may
      #      also contain the Escape character - less defaults to acting as if such
      #      files are binary).
      #    o Caseinsensetive searching (case sensetivity is enables if you use one
      #      or more uppercase letters).
      #    o Silent operation (never beep, bell character is displayed as ^G
      #      instead).
      #    o No clearing of screen on exit.
      #
    '';
  };
}
