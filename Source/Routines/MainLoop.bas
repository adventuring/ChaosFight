          rem ChaosFight - Source/Routines/MainLoop.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem Main game loop
MainLoop
          const pfres=18
          playfield:
          XXXXXXXXXXXXXXXX
          ................
          XXXXXXXXXXXXXXXX
          ................
          XXXXXXXXXXXXXXXX
          ................
          XXXXXXXXXXXXXXXX
          ................
          XXXXXXXXXXXXXXXX
          XXXXXXXXXXXXXXXX
          ................
          XXXXXXXXXXXXXXXX
          ................
          XXXXXXXXXXXXXXXX
          ................
          XXXXXXXXXXXXXXXX
          ................
          XXXXXXXXXXXXXXXX
end
          pfcolors:
           $00
           $00
           $00
           $00
           $00
           $00
           $00
           $00
           $00
           $00
           $00
           $00
           $00
           $00
           $00
           $00
end
          drawscreen
          goto MainLoop
