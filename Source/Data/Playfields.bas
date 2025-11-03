          rem ChaosFight - Source/Data/Playfields.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Arena playfield data (not generated - edit manually)


          rem PLAYFIELD DATA

          rem Game arenas: 16 pixels wide (left half) mirrored, 8 rows high (pfres=8)
          rem   Memory constraint: 8 rows × 4 bytes = 32 bytes (var96-var127)
          rem Admin screens: 32 pixels wide (asymmetrical), 32 rows high (pfres=32)
          rem   Memory constraint: 32 rows × 4 bytes = 128 bytes (var0-var127)
          rem Use X for solid, . for empty

          rem Arena 1: The Pit (classic fighting pit with walls)
Arena1Playfield
          playfield:
          XXXXXXXXXXXXXXXX
          X...............
          X...............
          X...............
          X...............
          X...............
          X...............
          XXXXXXXXXXXXXXXX
end
          return
          
#ifdef TV_SECAM
          rem SECAM: Always B&W mode - white on black
          pfcolors SharedPfColorsBW
#else
          rem NTSC/PAL: Check colorBWOverride for B&W vs Color mode
          if colorBWOverride then pfcolors SharedPfColorsBW : goto Arena1ColorsDone
          pfcolors Arena1ColorsColor
          ColOrange(2)
          ColOrange(4)
          ColOrange(6)
          ColOrange(8)
          ColOrange(10)
          ColOrange(12)
          ColOrange(14)
          ColOrange(0)
end
          return
Arena1ColorsDone
          return
          return

          rem Arena 2: Battlefield (platform fighter style)
Arena2Playfield
          playfield:
          ................
          ................
          ........XXXXXXXX
          ................
          ....XXXX........
          ................
          ................
          XXXXXXXXXXXXXXXX
end
          return
          
#ifdef TV_SECAM
          rem SECAM: Always B&W mode - white on black
          pfcolors SharedPfColorsBW
#else
          rem NTSC/PAL: Check colorBWOverride for B&W vs Color mode
          if colorBWOverride then pfcolors SharedPfColorsBW : goto Arena2ColorsDone
          pfcolors Arena2ColorsColor
          ColTurquoise(4)
          ColTurquoise(4)
          ColTurquoise(6)
          ColTurquoise(4)
          ColTurquoise(6)
          ColTurquoise(4)
          ColTurquoise(4)
          ColTurquoise(2)
end
          return

          rem Arena 3: King of the Hill (elevated center platform)
Arena3Playfield
          playfield:
          ................
          ................
          ............XXXX
          ............XXXX
          ............XXXX
          ................
          ................
          XXXXXXXXXXXXXXXX
end
          return
          
#ifdef TV_SECAM
          rem SECAM: Always B&W mode - white on black
          pfcolors SharedPfColorsBW
#else
          rem NTSC/PAL: Check colorBWOverride for B&W vs Color mode
          if !colorBWOverride then Pf3UseColorMode
          pfcolors SharedPfColorsBW
          goto Pf3ColorsDone
Pf3UseColorMode
          pfcolors Arena3ColorsColor
Pf3ColorsDone
          ColSeafoam(2)
          ColSeafoam(2)
          ColSeafoam(4)
          ColSeafoam(4)
          ColSeafoam(4)
          ColSeafoam(2)
          ColSeafoam(2)
          ColSeafoam(6)
end
          return

          rem Arena 4: The Bridge (narrow bridge over pit)
Arena4Playfield
          playfield:
          ................
          ................
          ................
          ....XXXXXXXX....
          ....XXXXXXXX....
          ................
          ................
          ................
end
          return

#ifdef TV_SECAM
          rem SECAM: Always B&W mode - white on black
          pfcolors SharedPfColorsBW
#else
          rem NTSC/PAL: Check colorBWOverride for B&W vs Color mode
          if !colorBWOverride then Pf4UseColorMode
          pfcolors SharedPfColorsBW
          goto Pf4ColorsDone
Pf4UseColorMode
          pfcolors Arena4ColorsColor
Pf4ColorsDone
          ColYellow(12)
          ColYellow(12)
          ColYellow(12)
          ColYellow(14)
          ColYellow(14)
          ColYellow(12)
          ColYellow(12)
          ColYellow(12)
end
          return

          rem Arena 5: Corner Trap (walls in corners)
Arena5Playfield
          playfield:
          XXXXXX..........
          XXXX............
          XX..............
          X...............
          X...............
          XX..............
          XXXX............
          XXXXXXXXXXXXXXXX
end
          return

#ifdef TV_SECAM
          rem SECAM: Always B&W mode - white on black
          pfcolors SharedPfColorsBW
#else
          rem NTSC/PAL: Check colorBWOverride for B&W vs Color mode
          if !colorBWOverride then Pf5UseColorMode
          pfcolors SharedPfColorsBW
          goto Pf5ColorsDone
Pf5UseColorMode
          pfcolors Arena5ColorsColor
Pf5ColorsDone
          ColBlue(4)
          ColBlue(4)
          ColBlue(4)
          ColBlue(4)
          ColBlue(4)
          ColBlue(4)
          ColBlue(4)
          ColBlue(4)
end
          return

          rem Arena 6: Multi-Platform (multiple small platforms)
Arena6Playfield
          playfield:
          ................
          ..XXXXXX........
          ................
          ......XXXX......
          ................
          XXXXXX..........
          ................
          XXXXXXXXXXXXXXXX
end
          return

#ifdef TV_SECAM
          rem SECAM: Always B&W mode - white on black
          pfcolors SharedPfColorsBW
#else
          rem NTSC/PAL: Check colorBWOverride for B&W vs Color mode
          if !colorBWOverride then Pf6UseColorMode
          pfcolors SharedPfColorsBW
          goto Pf6ColorsDone
Pf6UseColorMode
          pfcolors Arena6ColorsColor
Pf6ColorsDone
          ColRed(2)
          ColRed(4)
          ColRed(2)
          ColRed(6)
          ColRed(2)
          ColRed(4)
          ColRed(2)
          ColRed(8)
end
          return

          rem Arena 7: The Gauntlet (maze-like walls)
Arena7Playfield
          playfield:
          X......XXXX.....
          X......XXXX.....
          X...............
          XXXXXXXX........
          ................
          XXXXXXXX........
          X...............
          XXXXXXXXXXXXXXXX
end
          return

#ifdef TV_SECAM
          rem SECAM: Always B&W mode - white on black
          pfcolors SharedPfColorsBW
#else
          rem NTSC/PAL: Check colorBWOverride for B&W vs Color mode
          if !colorBWOverride then Pf7UseColorMode
          pfcolors SharedPfColorsBW
          goto Pf7ColorsDone
Pf7UseColorMode
          pfcolors Arena7ColorsColor
Pf7ColorsDone
          ColGold(2)
          ColGold(2)
          ColGold(2)
          ColGold(4)
          ColGold(2)
          ColGold(4)
          ColGold(2)
          ColGold(6)
end
          return

          rem Arena 8: Scattered Blocks (alternating block pattern)
Arena8Playfield
          playfield:
          X.X.X.X.X.X.X.X.
          ................
          ................
          ................
          ................
          ................
          ................
          X.X.X.X.X.X.X.X.
end
          return

#ifdef TV_SECAM
          rem SECAM: Always B&W mode - white on black
          pfcolors SharedPfColorsBW
#else
          rem NTSC/PAL: Check colorBWOverride for B&W vs Color mode
          if !colorBWOverride then Pf8UseColorMode
          pfcolors SharedPfColorsBW
          goto Pf8ColorsDone
Pf8UseColorMode
          pfcolors Arena8ColorsColor
Pf8ColorsDone
          ColPurple(2)
          ColPurple(4)
          ColPurple(4)
          ColPurple(4)
          ColPurple(4)
          ColPurple(4)
          ColPurple(4)
          ColPurple(2)
end
          return

          rem Arena 9: The Deep Pit (variant of Arena 1 with deeper walls)
Arena9Playfield
          playfield:
          XXXXXXXXXXXXXXXX
          XXX.............
          XXX.............
          XX..............
          XX..............
          XXX.............
          XXX.............
          XXXXXXXXXXXXXXXX
end
          return
          
#ifdef TV_SECAM
          rem SECAM: Always B&W mode - white on black
          pfcolors SharedPfColorsBW
#else
          rem NTSC/PAL: Check colorBWOverride for B&W vs Color mode
          if !colorBWOverride then Pf9UseColorMode
          pfcolors SharedPfColorsBW
          goto Pf9ColorsDone
Pf9UseColorMode
          pfcolors Arena9ColorsColor
Pf9ColorsDone
          ColRed(2)
          ColRed(4)
          ColRed(4)
          ColRed(6)
          ColRed(6)
          ColRed(4)
          ColRed(4)
          ColRed(2)
end
          return

          rem Arena 10: Sky Battlefield (variant of Arena 2 with elevated platforms)
Arena10Playfield
          playfield:
          ....XXXXXXXX....
          ................
          XXXXXX....XXXXXX
          ................
          ....XXXXXXXX....
          ................
          ................
          XXXXXXXXXXXXXXXX
end
          return
          
#ifdef TV_SECAM
          rem SECAM: Always B&W mode - white on black
          pfcolors SharedPfColorsBW
#else
          rem NTSC/PAL: Check colorBWOverride for B&W vs Color mode
          if !colorBWOverride then Pf10UseColorMode
          pfcolors SharedPfColorsBW
          goto Pf10ColorsDone
Pf10UseColorMode
          pfcolors Arena10ColorsColor
Pf10ColorsDone
          ColCyan(4)
          ColCyan(2)
          ColCyan(6)
          ColCyan(2)
          ColCyan(4)
          ColCyan(2)
          ColCyan(2)
          ColCyan(8)
end
          return

          rem Arena 11: Floating Platforms (variant of Arena 3 with four floating blocks when mirrored)
Arena11Playfield
          playfield:
          ................
          ..XXXX....XXXX..
          ..XXXX....XXXX..
          ..XXXX....XXXX..
          ..XXXX....XXXX..
          ................
          ................
          XXXXXXXXXXXXXXXX
end
          return
          
#ifdef TV_SECAM
          rem SECAM: Always B&W mode - white on black
          pfcolors SharedPfColorsBW
#else
          rem NTSC/PAL: Check colorBWOverride for B&W vs Color mode
          if !colorBWOverride then Pf11UseColorMode
          pfcolors SharedPfColorsBW
          goto Pf11ColorsDone
Pf11UseColorMode
          pfcolors Arena11ColorsColor
Pf11ColorsDone
          ColGreen(2)
          ColGreen(4)
          ColGreen(4)
          ColGreen(6)
          ColGreen(6)
          ColGreen(2)
          ColGreen(2)
          ColGreen(8)
end
          return

          rem Arena 12: The Chasm (variant of Arena 4 with wider bridge)
Arena12Playfield
          playfield:
          ................
          ................
          ..XXXXXXXXXXXX..
          ..XXXXXXXXXXXX..
          ..XXXXXXXXXXXX..
          ................
          ................
          ................
end
          return

#ifdef TV_SECAM
          rem SECAM: Always B&W mode - white on black
          pfcolors SharedPfColorsBW
#else
          rem NTSC/PAL: Check colorBWOverride for B&W vs Color mode
          if !colorBWOverride then Pf12UseColorMode
          pfcolors SharedPfColorsBW
          goto Pf12ColorsDone
Pf12UseColorMode
          pfcolors Arena12ColorsColor
Pf12ColorsDone
          ColBrown(12)
          ColBrown(12)
          ColBrown(14)
          ColBrown(14)
          ColBrown(14)
          ColBrown(12)
          ColBrown(12)
          ColBrown(12)
end
          return

          rem Arena 13: Fortress Walls (variant of Arena 5 with symmetrical corners)
Arena13Playfield
          playfield:
          XXX..XXXXXXX..XX
          XX....XXXX....XX
          X......XX......X
          ................
          ................
          X......XX......X
          XX....XXXX....XX
          XXX..XXXXXXX..XX
end
          return
          
#ifdef TV_SECAM
          rem SECAM: Always B&W mode - white on black
          pfcolors SharedPfColorsBW
#else
          rem NTSC/PAL: Check colorBWOverride for B&W vs Color mode
          if !colorBWOverride then Pf13UseColorMode
          pfcolors SharedPfColorsBW
          goto Pf13ColorsDone
Pf13UseColorMode
          pfcolors Arena13ColorsColor
Pf13ColorsDone
          ColTurquoise(4)
          ColTurquoise(4)
          ColTurquoise(6)
          ColTurquoise(2)
          ColTurquoise(2)
          ColTurquoise(6)
          ColTurquoise(4)
          ColTurquoise(4)
end
          return

          rem Arena 14: Floating Islands (variant of Arena 6 with more platforms)
Arena14Playfield
          playfield:
          .XX..XX..XX..XX.
          ................
          ..XXXX....XXXX..
          ................
          .XX..XX..XX..XX.
          ................
          ..XXXX....XXXX..
          XXXXXXXXXXXXXXXX
end
          return
          
#ifdef TV_SECAM
          rem SECAM: Always B&W mode - white on black
          pfcolors SharedPfColorsBW
#else
          rem NTSC/PAL: Check colorBWOverride for B&W vs Color mode
          if !colorBWOverride then Pf14UseColorMode
          pfcolors SharedPfColorsBW
          goto Pf14ColorsDone
Pf14UseColorMode
          pfcolors Arena14ColorsColor
Pf14ColorsDone
          ColMagenta(2)
          ColMagenta(0)
          ColMagenta(4)
          ColMagenta(0)
          ColMagenta(2)
          ColMagenta(0)
          ColMagenta(4)
          ColMagenta(8)
end
          return

          rem Arena 15: The Labyrinth (variant of Arena 7 with more complex maze)
Arena15Playfield
          playfield:
          XX..XXXX..XX..XX
          XX...............
          ....XX....XX....
          XXXX............
          ....XXXX....XXXX
          ..XX............
          ......XX....XX..
          XXXX..XXXX..XXXX
end
          return
          
#ifdef TV_SECAM
          rem SECAM: Always B&W mode - white on black
          pfcolors SharedPfColorsBW
#else
          rem NTSC/PAL: Check colorBWOverride for B&W vs Color mode
          if !colorBWOverride then Pf15UseColorMode
          pfcolors SharedPfColorsBW
          goto Pf15ColorsDone
Pf15UseColorMode
          pfcolors Arena15ColorsColor
Pf15ColorsDone
          ColSpringGreen(2)
          ColSpringGreen(2)
          ColSpringGreen(4)
          ColSpringGreen(6)
          ColSpringGreen(6)
          ColSpringGreen(4)
          ColSpringGreen(2)
          ColSpringGreen(8)
end
          return

          rem Arena 16: Danger Zone (variant of Arena 8 with alternating obstacles)
Arena16Playfield
          playfield:
          .X.X.X.X.X.X.X.X
          ................
          X.X.X.X.X.X.X.X.
          ................
          .X.X.X.X.X.X.X.X
          ................
          X.X.X.X.X.X.X.X.
          .X.X.X.X.X.X.X.X
end
          return
          
#ifdef TV_SECAM
          rem SECAM: Always B&W mode - white on black
          pfcolors SharedPfColorsBW
#else
          rem NTSC/PAL: Check colorBWOverride for B&W vs Color mode
          if !colorBWOverride then Pf16UseColorMode
          pfcolors SharedPfColorsBW
          goto Pf16ColorsDone
Pf16UseColorMode
          pfcolors Arena16ColorsColor
Pf16ColorsDone
          ColIndigo(2)
          ColIndigo(4)
          ColIndigo(6)
          ColIndigo(4)
          ColIndigo(6)
          ColIndigo(4)
          ColIndigo(6)
          ColIndigo(8)
end
          return

          rem =================================================================
          rem SHARED PFCOLORS SECTIONS
          rem =================================================================
          rem All B&W pfcolors reference this single shared section
          rem to avoid code duplication and save memory

SharedPfColorsBW:
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
end
          return
          ColGrey(14)
          ColGrey(14)
end
          return
