          rem ChaosFight - Source/Data/Arenas.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Arena playfield data (not generated - edit manually)

          rem Arena Data - Pure Data Format
          rem
          rem Game arenas: 16 pixels wide (left half) mirrored, 8 rows
          rem   high (pfres=8)
          rem Memory constraint: 8 rows × 4 bytes = 32 bytes
          rem   (var96-var127)
          rem Use X for solid, . = empty
          rem
          rem Each arena has:
          rem   - ArenaXPlayfield: playfield pixel data
          rem - ArenaXColorsColor: row colors for Color mode
          rem   (switchbw=0)
          rem All arenas share ArenaColorsBW for B&W mode
          rem ==========================================================

          rem Shared B&w Color Definition
          rem
          rem All arenas use the same B&W colors (all white)
          rem ==========================================================
ArenaColorsBW
          pfcolors:
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
end

          rem Arena Playfields (32 Arenas: Indices 0-31)
          rem
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
          pfcolors:
          ColOrange(2)
          ColOrange(4)
          ColOrange(6)
          ColOrange(8)
          ColOrange(10)
          ColOrange(12)
          ColOrange(14)
          ColOrange(0)
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
          pfcolors:
          ColTurquoise(4)
          ColTurquoise(4)
          ColTurquoise(6)
          ColTurquoise(4)
          ColTurquoise(6)
          ColTurquoise(4)
          ColTurquoise(4)
          ColTurquoise(2)
end

Arena2Playfield
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

Arena2Colors
          pfcolors:
          ColTurquoise(4)
          ColTurquoise(4)
          ColTurquoise(6)
          ColTurquoise(4)
          ColTurquoise(6)
          ColTurquoise(4)
          ColTurquoise(4)
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
          pfcolors:
          ColSeafoam(2)
          ColSeafoam(2)
          ColSeafoam(4)
          ColSeafoam(4)
          ColSeafoam(4)
          ColSeafoam(2)
          ColSeafoam(2)
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
          pfcolors:
          ColYellow(12)
          ColYellow(12)
          ColYellow(12)
          ColYellow(14)
          ColYellow(14)
          ColYellow(12)
          ColYellow(12)
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
          pfcolors:
          ColBlue(4)
          ColBlue(4)
          ColBlue(4)
          ColBlue(4)
          ColBlue(4)
          ColBlue(4)
          ColBlue(4)
          ColBlue(4)
end

          rem Arena 6: Multi-Platform (multiple small platforms)
Arena6Playfield
          playfield:
          X...............
          X.XXXXXX........
          X...............
          X.....XXXX......
          X...............
          XXXXXX..........
          X...............
          XXXXXXXXXXXXXXXX
end

Arena6Colors
          pfcolors:
          ColRed(2)
          ColRed(4)
          ColRed(2)
          ColRed(6)
          ColRed(2)
          ColRed(4)
          ColRed(2)
          ColRed(8)
end

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

Arena7Colors
          pfcolors:
          ColGold(2)
          ColGold(2)
          ColGold(2)
          ColGold(4)
          ColGold(2)
          ColGold(4)
          ColGold(2)
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
          pfcolors:
          ColPurple(2)
          ColPurple(4)
          ColPurple(6)
          ColPurple(4)
          ColPurple(6)
          ColPurple(4)
          ColPurple(6)
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
          pfcolors:
          ColRed(2)
          ColRed(4)
          ColRed(6)
          ColRed(4)
          ColRed(4)
          ColRed(6)
          ColRed(4)
          ColRed(2)
end

          rem Arena 10: Sky Battlefield (variant of Arena 2 with
          rem   elevated platforms)
Arena10Playfield
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
          pfcolors:
          ColCyan(4)
          ColCyan(2)
          ColCyan(6)
          ColCyan(2)
          ColCyan(4)
          ColCyan(2)
          ColCyan(2)
          ColCyan(8)
end


          rem Arena 11: Floating Platforms (variant of Arena 3 with four
          rem   floating blocks when mirrored)
Arena11Playfield
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
          pfcolors:
          ColGreen(2)
          ColGreen(4)
          ColGreen(4)
          ColGreen(6)
          ColGreen(6)
          ColGreen(2)
          ColGreen(2)
          ColGreen(8)
end

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

Arena12Colors
          pfcolors:
          ColBrown(12)
          ColBrown(12)
          ColBrown(14)
          ColBrown(14)
          ColBrown(14)
          ColBrown(12)
          ColBrown(12)
          ColBrown(12)
end

          rem Arena 13: Fortress Walls (variant of Arena 5 with
          rem   symmetrical corners)
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

Arena13Colors
          pfcolors:
          ColTurquoise(4)
          ColTurquoise(4)
          ColTurquoise(6)
          ColTurquoise(2)
          ColTurquoise(2)
          ColTurquoise(6)
          ColTurquoise(4)
          ColTurquoise(4)
end

          rem Arena 14: Floating Islands (variant of Arena 6 with more
          rem   platforms)
Arena14Playfield
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
          pfcolors:
          ColMagenta(2)
          ColMagenta(0)
          ColMagenta(4)
          ColMagenta(0)
          ColMagenta(2)
          ColMagenta(0)
          ColMagenta(4)
          ColMagenta(8)
end

          rem Arena 15: The Labyrinth (variant of Arena 7 with more
          rem   complex maze)
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

Arena15Colors
          pfcolors:
          ColSpringGreen(2)
          ColSpringGreen(2)
          ColSpringGreen(4)
          ColSpringGreen(6)
          ColSpringGreen(6)
          ColSpringGreen(4)
          ColSpringGreen(2)
          ColSpringGreen(8)
end

          rem Arena 16: Danger Zone (variant of Arena 8 with alternating
          rem   obstacles)
Arena16Playfield
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
          pfcolors:
          ColIndigo(2)
          ColIndigo(4)
          ColIndigo(6)
          ColIndigo(4)
          ColIndigo(6)
          ColIndigo(4)
          ColIndigo(6)
          ColIndigo(8)
end

          rem Arena 17: The Spire (vertical tower platforms)
Arena17Playfield
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
          pfcolors:
          ColGreen(2)
          ColGreen(4)
          ColGreen(6)
          ColGreen(4)
          ColGreen(6)
          ColGreen(4)
          ColGreen(2)
          ColGreen(8)
end

          rem Arena 18: The Bridge (wide center platform)
Arena18Playfield
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
          pfcolors:
          ColTeal(12)
          ColTeal(12)
          ColTeal(12)
          ColTeal(14)
          ColTeal(14)
          ColTeal(12)
          ColTeal(12)
          ColTeal(12)
end

          rem Arena 19: The Pits (narrow platforms with gaps)
Arena19Playfield
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
          pfcolors:
          ColRed(2)
          ColRed(2)
          ColRed(0)
          ColRed(2)
          ColRed(2)
          ColRed(0)
          ColRed(2)
          ColRed(4)
end

          rem Arena 20: The Stairs (stepped platforms)
Arena20Playfield
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
          pfcolors:
          ColBlue(4)
          ColBlue(4)
          ColBlue(4)
          ColBlue(6)
          ColBlue(6)
          ColBlue(8)
          ColBlue(8)
          ColBlue(2)
end

          rem Arena 21: The Grid (checkerboard pattern)
Arena21Playfield
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
          pfcolors:
          ColBrown(4)
          ColBrown(4)
          ColBrown(6)
          ColBrown(6)
          ColBrown(4)
          ColBrown(4)
          ColBrown(6)
          ColBrown(6)
end

          rem Arena 22: The Columns (vertical pillars)
Arena22Playfield
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
          pfcolors:
          ColRed(4)
          ColRed(4)
          ColRed(4)
          ColRed(4)
          ColRed(4)
          ColRed(4)
          ColRed(4)
          ColRed(6)
end

          rem Arena 23: The Waves (curved platforms)
Arena23Playfield
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
          pfcolors:
          ColCyan(2)
          ColCyan(4)
          ColCyan(4)
          ColCyan(2)
          ColCyan(4)
          ColCyan(4)
          ColCyan(2)
          ColCyan(6)
end

          rem Arena 24: The Cross (cross-shaped platform)
Arena24Playfield
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
          pfcolors:
          ColGrey(4)
          ColGrey(4)
          ColGrey(4)
          ColGrey(6)
          ColGrey(6)
          ColGrey(4)
          ColGrey(4)
          ColGrey(4)
end

          rem Arena 25: The Maze (complex wall pattern)
Arena25Playfield
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
          pfcolors:
          ColPurple(2)
          ColPurple(4)
          ColPurple(6)
          ColPurple(8)
          ColPurple(8)
          ColPurple(6)
          ColPurple(4)
          ColPurple(2)
end

          rem Arena 26: The Islands (scattered platforms)
Arena26Playfield
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
          pfcolors:
          ColOrange(2)
          ColOrange(2)
          ColOrange(0)
          ColOrange(4)
          ColOrange(4)
          ColOrange(0)
          ColOrange(2)
          ColOrange(2)
end

          rem Arena 27: The Rings (concentric platforms)
Arena27Playfield
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
          pfcolors:
          ColYellow(2)
          ColYellow(4)
          ColYellow(6)
          ColYellow(8)
          ColYellow(8)
          ColYellow(6)
          ColYellow(4)
          ColYellow(2)
end

          rem Arena 28: The Slopes (diagonal platforms)
Arena28Playfield
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
          pfcolors:
          ColGreen(2)
          ColGreen(4)
          ColGreen(6)
          ColGreen(8)
          ColGreen(8)
          ColGreen(6)
          ColGreen(4)
          ColGreen(2)
end

          rem Arena 29: The Zigzag (zigzag pattern)
Arena29Playfield
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
          pfcolors:
          ColMagenta(2)
          ColMagenta(4)
          ColMagenta(6)
          ColMagenta(4)
          ColMagenta(4)
          ColMagenta(6)
          ColMagenta(4)
          ColMagenta(2)
end

          rem Arena 30: The Ladder (vertical rungs)
Arena30Playfield
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
          pfcolors:
          ColSpringGreen(4)
          ColSpringGreen(4)
          ColSpringGreen(4)
          ColSpringGreen(4)
          ColSpringGreen(4)
          ColSpringGreen(4)
          ColSpringGreen(4)
          ColSpringGreen(6)
end

          rem Arena 31: The Final Battle (complex multi-platform)
Arena31Playfield
          playfield:
          XXXXXXXXXXXXXXXX
          X.XX..XX..XX.XX.X
          X.XX..XX..XX.XX.X
          X..............X
          X.XX..XX..XX.XX.X
          X.XX..XX..XX.XX.X
          X..............X
          XXXXXXXXXXXXXXXX
end

Arena31Colors
          pfcolors:
          ColGrey(2)
          ColGrey(4)
          ColGrey(4)
          ColGrey(6)
          ColGrey(4)
          ColGrey(4)
          ColGrey(6)
          ColGrey(8)
end

          rem Arena Pointer Tables
          rem
          rem Playfield pointer lookup tables for efficient arena loading
          rem Format: 32 entries (indices 0-31) for Arena0-Arena31
          rem Note: PF1 and PF2 both point to the same ArenaNPlayfield
          rem ==========================================================

          data ArenaPF1PointerL
            <Arena0Playfield, <Arena1Playfield, <Arena2Playfield, <Arena3Playfield, <Arena4Playfield, <Arena5Playfield, <Arena6Playfield, <Arena7Playfield,
            <Arena8Playfield, <Arena9Playfield, <Arena10Playfield, <Arena11Playfield, <Arena12Playfield, <Arena13Playfield, <Arena14Playfield, <Arena15Playfield,
            <Arena16Playfield, <Arena17Playfield, <Arena18Playfield, <Arena19Playfield, <Arena20Playfield, <Arena21Playfield, <Arena22Playfield, <Arena23Playfield,
            <Arena24Playfield, <Arena25Playfield, <Arena26Playfield, <Arena27Playfield, <Arena28Playfield, <Arena29Playfield, <Arena30Playfield, <Arena31Playfield
end

          data ArenaPF1PointerH
            >Arena0Playfield, >Arena1Playfield, >Arena2Playfield, >Arena3Playfield, >Arena4Playfield, >Arena5Playfield, >Arena6Playfield, >Arena7Playfield,
            >Arena8Playfield, >Arena9Playfield, >Arena10Playfield, >Arena11Playfield, >Arena12Playfield, >Arena13Playfield, >Arena14Playfield, >Arena15Playfield,
            >Arena16Playfield, >Arena17Playfield, >Arena18Playfield, >Arena19Playfield, >Arena20Playfield, >Arena21Playfield, >Arena22Playfield, >Arena23Playfield,
            >Arena24Playfield, >Arena25Playfield, >Arena26Playfield, >Arena27Playfield, >Arena28Playfield, >Arena29Playfield, >Arena30Playfield, >Arena31Playfield
end

          data ArenaPF2PointerL
            <Arena0Playfield, <Arena1Playfield, <Arena2Playfield, <Arena3Playfield, <Arena4Playfield, <Arena5Playfield, <Arena6Playfield, <Arena7Playfield,
            <Arena8Playfield, <Arena9Playfield, <Arena10Playfield, <Arena11Playfield, <Arena12Playfield, <Arena13Playfield, <Arena14Playfield, <Arena15Playfield,
            <Arena16Playfield, <Arena17Playfield, <Arena18Playfield, <Arena19Playfield, <Arena20Playfield, <Arena21Playfield, <Arena22Playfield, <Arena23Playfield,
            <Arena24Playfield, <Arena25Playfield, <Arena26Playfield, <Arena27Playfield, <Arena28Playfield, <Arena29Playfield, <Arena30Playfield, <Arena31Playfield
end

          data ArenaPF2PointerH
            >Arena0Playfield, >Arena1Playfield, >Arena2Playfield, >Arena3Playfield, >Arena4Playfield, >Arena5Playfield, >Arena6Playfield, >Arena7Playfield,
            >Arena8Playfield, >Arena9Playfield, >Arena10Playfield, >Arena11Playfield, >Arena12Playfield, >Arena13Playfield, >Arena14Playfield, >Arena15Playfield,
            >Arena16Playfield, >Arena17Playfield, >Arena18Playfield, >Arena19Playfield, >Arena20Playfield, >Arena21Playfield, >Arena22Playfield, >Arena23Playfield,
            >Arena24Playfield, >Arena25Playfield, >Arena26Playfield, >Arena27Playfield, >Arena28Playfield, >Arena29Playfield, >Arena30Playfield, >Arena31Playfield
end

