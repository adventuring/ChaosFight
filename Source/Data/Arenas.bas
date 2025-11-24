          rem
          rem ChaosFight - Source/Data/Arenas.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Arena playfield data (not generated - edit manually)
          rem
          rem   high (pfres=8)
          rem   (var96-var127)
          rem Use X for solid, . = empty
          rem Each arena has:
          rem   - ArenaXPlayfield: playfield pixel data
          rem
          rem - ArenaXColorsColor: row colors for Color mode
          rem   (switchbw=0)
          rem All arenas share ArenaColorsBW for B&W mode
          rem Shared B&w Color Definition
          rem All arenas use the same B&W colors (all white)
          rem
          rem Suppress pointer-setting code to maintain 24-byte alignment
          rem LoadArenaByIndex routine handles pointer calculation dynamically
          const _suppress_pf_pointer_code = 1
          asm
ArenaColorsBWStart
end
data ArenaColorsBW
ColGrey(14),
ColGrey(14),
ColGrey(14),
ColGrey(14),
ColGrey(14),
ColGrey(14),
ColGrey(14),
ColGrey(14)
end
          asm
ArenaColorsBWEnd
end

          rem
          rem Blank playfield for score/transition frames.
          rem This does not participate in the indexed Arena0-31 system and is
          rem loaded explicitly when we want a neutral background behind the
          rem score/kernel.
          asm
BlankPlayfieldStart
end
BlankPlayfield
          asm
BlankPlayfield
end
          playfield:
          ................
          ................
          ................
          ................
          ................
          ................
          ................
          ................
end
          asm
BlankPlayfieldEnd
end
          asm
BlankPlayfieldColorsStart
end
BlankPlayfieldColors
data BlankPlayfieldColors
ColGrey(14),
ColGrey(14),
ColGrey(14),
ColGrey(14),
ColGrey(14),
ColGrey(14),
ColGrey(14),
ColGrey(14)
end
          asm
BlankPlayfieldColorsEnd
Arena0PlayfieldStart
end

          rem
          rem Arena Playfields (32 Arenas: Indices 0-31)
          
Arena0Playfield
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
Arena0Colors
data Arena0Colors
ColBrown(2),
ColBrown(4),
ColBrown(6),
ColBrown(8),
ColBrown(10),
ColBrown(12),
ColBrown(14),
ColBrown(0)
end
Arena1Playfield
          playfield:
          X...............
          X...............
          X.......XXXXXXXX
          X...............
          X...XXXX........
          X...............
          X...............
          XXXXXXXXXXXXXXXX
end
Arena1Colors
data Arena1Colors
ColTurquoise(4),
ColTurquoise(4),
ColTurquoise(6),
ColTurquoise(4),
ColTurquoise(6),
ColTurquoise(4),
ColTurquoise(4),
ColTurquoise(2)
end
Arena2Playfield
          playfield:
          XXXXX...........
          X...............
          ................
          ................
          XXXXX.......XXXX
          X...............
          X...............
          XXXXXXXXXXXXXXXX
end
Arena2Colors
data Arena2Colors
ColTurquoise(4),
ColTurquoise(4),
ColTurquoise(6),
ColTurquoise(4),
ColTurquoise(6),
ColTurquoise(4),
ColTurquoise(4),
ColTurquoise(2)
end
Arena3Playfield
          playfield:
          X...............
          X...............
          X...........XXXX
          X...........XXXX
          X...........XXXX
          X...............
          X...............
          XXXXXXXXXXXXXXXX
end
Arena3Colors
data Arena3Colors
ColSeafoam(2),
ColSeafoam(2),
ColSeafoam(4),
ColSeafoam(4),
ColSeafoam(4),
ColSeafoam(2),
ColSeafoam(2),
ColSeafoam(6)
end
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
Arena4Colors
data Arena4Colors
ColYellow(12),
ColYellow(12),
ColYellow(12),
ColYellow(14),
ColYellow(14),
ColYellow(12),
ColYellow(12),
ColYellow(12)
end
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
Arena5Colors
data Arena5Colors
ColBlue(4),
ColBlue(4),
ColBlue(4),
ColBlue(4),
ColBlue(4),
ColBlue(4),
ColBlue(4),
ColBlue(4)
end
Arena6Playfield
          rem Arena 6: Multi-Platform (multiple small platforms)
          playfield:
          X...............
          X..XXXXX........
          X...............
          X.....XXXX......
          X...............
          XXXXXX..........
          X...............
          XXXXXXXXXXXXXXXX
end
Arena6Colors
data Arena6Colors
ColRed(2),
ColRed(4),
ColRed(2),
ColRed(6),
ColRed(2),
ColRed(4),
ColRed(2),
ColRed(8)
end
Arena7Playfield
          rem Arena 7: The Gauntlet (maze-like walls)
          playfield:
          X......XXXX.....
          X......XXXX.....
          XXX.............
          ................
          ................
          XXXXXXXX........
          X...............
          XXXXXXXXXXXXXXXX
end
Arena7Colors
data Arena7Colors
ColGold(2),
ColGold(2),
ColGold(2),
ColGold(4),
ColGold(2),
ColGold(4),
ColGold(2),
ColGold(6)
end
Arena8Playfield
          playfield:
          XXXXXXXXXXXXXXXX
          X...............
          X...XXXX........
          X...............
          X.......XXXX....
          X...............
          X...XXXX........
          XXXXXXXXXXXXXXXX
end
Arena8Colors
data Arena8Colors
ColPurple(2),
ColPurple(4),
ColPurple(6),
ColPurple(4),
ColPurple(6),
ColPurple(4),
ColPurple(6),
ColPurple(2)
end
Arena9Playfield
          playfield:
          XXXXXXXXXXXXXXXX
          X...............
          X.XXXX....XXXX..
          X...............
          X...............
          X.XXXX....XXXX..
          X...............
          XXXXXXXXXXXXXXXX
end
Arena9Colors
data Arena9Colors
ColRed(2),
ColRed(4),
ColRed(6),
ColRed(4),
ColRed(4),
ColRed(6),
ColRed(4),
ColRed(2)
end
Arena10Playfield
          rem Arena 10: Sky Battlefield (variant of Arena 2 with
          rem   elevated platforms)
          playfield:
          X...XXXXXXXX....
          X...............
          XXXXXX....XXXXXX
          X...............
          X...XXXXXXXX....
          X...............
          X...............
          XXXXXXXXXXXXXXXX
end
Arena10Colors
data Arena10Colors
ColCyan(4),
ColCyan(2),
ColCyan(6),
ColCyan(2),
ColCyan(4),
ColCyan(2),
ColCyan(2),
ColCyan(8)
end
          rem Arena color/playfield pointers computed at runtime to save ROM
Arena11Playfield
          rem Arena 11: Floating Platforms (variant of Arena 3 with four
          rem   floating blocks when mirrored)
          playfield:
          X...............
          X.XXXX....XXXX..
          X.XXXX....XXXX..
          X.XXXX....XXXX..
          X.XXXX....XXXX..
          X...............
          X...............
          XXXXXXXXXXXXXXXX
end
Arena11Colors
data Arena11Colors
ColGreen(2),
ColGreen(4),
ColGreen(4),
ColGreen(6),
ColGreen(6),
ColGreen(2),
ColGreen(2),
ColGreen(8)
end
Arena12Playfield
          rem Arena 12: The Chasm (variant of Arena 4 with wider bridge)
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
Arena12Colors
data Arena12Colors
ColBrown(12),
ColBrown(12),
ColBrown(14),
ColBrown(14),
ColBrown(14),
ColBrown(12),
ColBrown(12),
ColBrown(12)
end
Arena13Playfield
          rem Arena 13: Fortress Walls (variant of Arena 5 with
          rem   symmetrical corners)
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
Arena13Colors
data Arena13Colors
ColTurquoise(4),
ColTurquoise(4),
ColTurquoise(6),
ColTurquoise(2),
ColTurquoise(2),
ColTurquoise(6),
ColTurquoise(4),
ColTurquoise(4)
end
Arena14Playfield
          rem Arena 14: Floating Islands (variant of Arena 6 with more
          rem   platforms)
          playfield:
          X.XX..XX..XX..XX.
          X...............
          X.XXXX....XXXX..
          X...............
          X.XX..XX..XX..XX.
          X...............
          X.XXXX....XXXX..
          XXXXXXXXXXXXXXXX
end
Arena14Colors
data Arena14Colors
ColMagenta(2),
ColMagenta(0),
ColMagenta(4),
ColMagenta(0),
ColMagenta(2),
ColMagenta(0),
ColMagenta(4),
ColMagenta(8)
end
Arena15Playfield
          rem Arena 15: The Labyrinth (variant of Arena 7 with more
          rem   complex maze)
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
Arena15Colors
data Arena15Colors
ColSpringGreen(2),
ColSpringGreen(2),
ColSpringGreen(4),
ColSpringGreen(6),
ColSpringGreen(6),
ColSpringGreen(4),
ColSpringGreen(2),
ColSpringGreen(8)
end
Arena16Playfield
          rem Arena 16: Danger Zone (variant of Arena 8 with alternating
          rem   obstacles)
          playfield:
          XX.X.X.X.X.X.X.X
          X...............
          XX.X.X.X.X.X.X.X
          X...............
          XX.X.X.X.X.X.X.X
          X...............
          XX.X.X.X.X.X.X.X
          XX.X.X.X.X.X.X.X
end
Arena16Colors
data Arena16Colors
ColIndigo(2),
ColIndigo(4),
ColIndigo(6),
ColIndigo(4),
ColIndigo(6),
ColIndigo(4),
ColIndigo(6),
ColIndigo(8)
end
Arena17Playfield
          rem Arena 17: The Spire (vertical tower platforms)
          playfield:
          XXXXXXXXXXXXXXXX
          X...............
          X......XX.......
          X...............
          X......XX.......
          X...............
          X......XX.......
          XXXXXXXXXXXXXXXX
end
Arena17Colors
data Arena17Colors
ColGreen(2),
ColGreen(4),
ColGreen(6),
ColGreen(4),
ColGreen(6),
ColGreen(4),
ColGreen(2),
ColGreen(8)
end
Arena18Playfield
          rem Arena 18: The Bridge (wide center platform)
          playfield:
          ................
          ................
          ................
          XXXXXXXXXXXXXXXX
          XXXXXXXXXXXXXXXX
          ................
          ................
          ................
end
Arena18Colors
data Arena18Colors
ColTeal(12),
ColTeal(12),
ColTeal(12),
ColTeal(14),
ColTeal(14),
ColTeal(12),
ColTeal(12),
ColTeal(12)
end
Arena19Playfield
          rem Arena 19: The Pits (narrow platforms with gaps)
          playfield:
          XXXX........XXXX
          XXXX........XXXX
          ................
          XXXX........XXXX
          XXXX........XXXX
          ................
          XXXX........XXXX
          XXXX........XXXX
end
Arena19Colors
data Arena19Colors
ColRed(2),
ColRed(2),
ColRed(0),
ColRed(2),
ColRed(2),
ColRed(0),
ColRed(2),
ColRed(4)
end
Arena20Playfield
          rem Arena 20: The Stairs (stepped platforms)
          playfield:
          XXXXXXXXXXXXXXXX
          XXXX............
          XXXX............
          XX..............
          XX..............
          X...............
          X...............
          XXXXXXXXXXXXXXXX
end
Arena20Colors
data Arena20Colors
ColBlue(4),
ColBlue(4),
ColBlue(4),
ColBlue(6),
ColBlue(6),
ColBlue(8),
ColBlue(8),
ColBlue(2)
end
Arena21Playfield
          rem Arena 21: The Grid (checkerboard pattern)
          playfield:
          XX..XX..XX..XX..
          XX..XX..XX..XX..
          ..XX..XX..XX..XX
          ..XX..XX..XX..XX
          XX..XX..XX..XX..
          XX..XX..XX..XX..
          ..XX..XX..XX..XX
          ..XX..XX..XX..XX
end
Arena21Colors
data Arena21Colors
ColBrown(4),
ColBrown(4),
ColBrown(6),
ColBrown(6),
ColBrown(4),
ColBrown(4),
ColBrown(6),
ColBrown(6)
end
Arena22Playfield
          rem Arena 22: The Columns (vertical pillars)
          playfield:
          X..X..X..X..X..X
          X..X..X..X..X..X
          X..X..X..X..X..X
          X..X..X..X..X..X
          X..X..X..X..X..X
          X..X..X..X..X..X
          X..X..X..X..X..X
          X..X..X..X..X..X
end
Arena22Colors
data Arena22Colors
ColRed(4),
ColRed(4),
ColRed(4),
ColRed(4),
ColRed(4),
ColRed(4),
ColRed(4),
ColRed(6)
end
Arena23Playfield
          rem Arena 23: The Waves (curved platforms)
          playfield:
          XXXXXXXXXXXXXXXX
          XXXX............
          XXXX............
          XXXXXXXXXXXXXXXX
          XXXX............
          XXXX............
          XXXXXXXXXXXXXXXX
          XXXXXXXXXXXXXXXX
end
Arena23Colors
data Arena23Colors
ColCyan(2),
ColCyan(4),
ColCyan(4),
ColCyan(2),
ColCyan(4),
ColCyan(4),
ColCyan(2),
ColCyan(6)
end
Arena24Playfield
          rem Arena 24: The Cross (cross-shaped platform)
          playfield:
          XXXX....XXXX....
          XXXX....XXXX....
          XXXX....XXXX....
          XXXXXXXXXXXXXXXX
          XXXXXXXXXXXXXXXX
          XXXX....XXXX....
          XXXX....XXXX....
          XXXX....XXXX....
end
Arena24Colors
data Arena24Colors
ColGrey(4),
ColGrey(4),
ColGrey(4),
ColGrey(6),
ColGrey(6),
ColGrey(4),
ColGrey(4),
ColGrey(4)
end
Arena25Playfield
          rem Arena 25: The Maze (complex wall pattern)
          playfield:
          XXXXXXXXXXXXXXXX
          X......X......X
          X.XXXX.X.XXXX.X
          X.X..X.X.X..X.X
          X.X..X.X.X..X.X
          X.XXXX.X.XXXX.X
          X......X......X
          XXXXXXXXXXXXXXXX
end
Arena25Colors
data Arena25Colors
ColPurple(2),
ColPurple(4),
ColPurple(6),
ColPurple(8),
ColPurple(8),
ColPurple(6),
ColPurple(4),
ColPurple(2)
end
Arena26Playfield
          rem Arena 26: The Islands (scattered platforms)
          playfield:
          XX............XX
          XX............XX
          ................
          ....XXXXXX......
          ....XXXXXX......
          ................
          XX............XX
          XX............XX
end
Arena26Colors
data Arena26Colors
ColOrange(2),
ColOrange(2),
ColOrange(0),
ColOrange(4),
ColOrange(4),
ColOrange(0),
ColOrange(2),
ColOrange(2)
end
Arena27Playfield
          rem Arena 27: The Rings (concentric platforms)
          playfield:
          XXXXXXXXXXXXXXXX
          X..............X
          X.XXXXXXXXXXXX.X
          X.X..........X.X
          X.X..........X.X
          X.XXXXXXXXXXXX.X
          X..............X
          XXXXXXXXXXXXXXXX
end
Arena27Colors
data Arena27Colors
ColYellow(2),
ColYellow(4),
ColYellow(6),
ColYellow(8),
ColYellow(8),
ColYellow(6),
ColYellow(4),
ColYellow(2)
end
Arena28Playfield
          rem Arena 28: The Slopes (diagonal platforms)
          playfield:
          XXXXXXXXXXXXXXXX
          .XXXXXXXXXXXXXX.
          ..XXXXXXXXXXXX..
          ...XXXXXXXXXX...
          ...XXXXXXXXXX...
          ..XXXXXXXXXXXX..
          .XXXXXXXXXXXXXX.
          XXXXXXXXXXXXXXXX
end
Arena28Colors
data Arena28Colors
ColGreen(2),
ColGreen(4),
ColGreen(6),
ColGreen(8),
ColGreen(8),
ColGreen(6),
ColGreen(4),
ColGreen(2)
end
Arena29Playfield
          rem Arena 29: The Zigzag (zigzag pattern)
          playfield:
          XXXX........XXXX
          ..XXXX....XXXX..
          ....XXXXXX......
          ......XXXX......
          ......XXXX......
          ....XXXXXX......
          ..XXXX....XXXX..
          XXXX........XXXX
end
Arena29Colors
data Arena29Colors
ColMagenta(2),
ColMagenta(4),
ColMagenta(6),
ColMagenta(4),
ColMagenta(4),
ColMagenta(6),
ColMagenta(4),
ColMagenta(2)
end
Arena30Playfield
          rem Arena 30: The Ladder (vertical rungs)
          playfield:
          X..X..X..X..X..X
          X..X..X..X..X..X
          X..X..X..X..X..X
          X..X..X..X..X..X
          X..X..X..X..X..X
          X..X..X..X..X..X
          X..X..X..X..X..X
          X..X..X..X..X..X
end
Arena30Colors
data Arena30Colors
ColSpringGreen(4),
ColSpringGreen(4),
ColSpringGreen(4),
ColSpringGreen(4),
ColSpringGreen(4),
ColSpringGreen(4),
ColSpringGreen(4),
ColSpringGreen(6)
end
Arena31Playfield
          rem Arena 31: The Final Battle (complex multi-platform)
          playfield:
          XXXXXXXXXXXXXXXX
          X.XX..XX..XX.XX.
          X.XX..XX..XX.XX.
          X..............X
          X.XX..XX..XX.XX.
          X.XX..XX..XX.XX.
          X..............X
          XXXXXXXXXXXXXXXX
end
Arena31Colors
data Arena31Colors
ColGrey(2),
ColGrey(4),
ColGrey(4),
ColGrey(6),
ColGrey(4),
ColGrey(4),
ColGrey(6),
ColGrey(8)
end
          asm
Arena31PlayfieldEnd
Bank16AfterArenas
end
