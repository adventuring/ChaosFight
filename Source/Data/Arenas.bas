          rem ChaosFight - Source/Data/Arenas.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Arena playfield data (not generated - edit manually)

          rem ==========================================================
          rem ARENA DATA - PURE DATA FORMAT
          rem ==========================================================
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
          rem - ArenaXColorsBW: row colors for B&W mode (switchbw=1) -
          rem   all white
          rem ==========================================================

          rem Winner Screen: Podium/Platform pattern
          rem 32×32 admin screen layout (pfres=32)
          rem Design: Central high podium for winner, side platforms for
          rem   2nd/3rd
          rem Row 16: Central high platform (winner podium)
          rem Row 24: Left and right platforms (2nd/3rd place)
WinnerScreenPlayfield
          playfield:
          XXXXXXXXXXXXXXXX
          X...............
          X...............
          X...............
          X...............
          X...............
          X...............
          X...............
          X...............
          X...............
          X...............
          X...............
          X...............
          X...............
          X...............
          X...............
          X......XXXXXXXXX
          rem Row 16: Central high podium (left half - mirrors to full
          rem   width)
          X...............
          X...............
          X...............
          X...............
          X...............
          X...............
          X...............
          X...............
          X...............
          X...............
          X...............
          X...............
          X......XXXXXXXXX
          rem Row 24: Bottom platforms (left half - mirrors to full
          rem   width)
          X...............
          X...............
          X...............
          X...............
          XXXXXXXXXXXXXXXX
end

WinnerScreenColorsColor
          pfcolors:
          ColGold(14)
          ColGold(12)
          ColGold(10)
          ColGold(8)
          ColGold(6)
          ColGold(4)
          ColGold(2)
          ColGold(0)
          ColGold(2)
          ColGold(4)
          ColGold(6)
          ColGold(8)
          ColGold(10)
          ColGold(12)
          ColGold(14)
          ColGold(14)
          ColGold(14)
          ColGold(14)
          ColGold(14)
          ColGold(14)
          ColGold(14)
          ColGold(14)
          ColGold(14)
          ColGold(14)
          ColGold(14)
          ColGold(14)
          ColGold(14)
          ColGold(14)
          ColGold(14)
          ColGold(14)
          ColGold(14)
          ColGold(14)
end

WinnerScreenColorsBW
          pfcolors:
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
          ColGrey(14)
end

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

Arena1ColorsColor
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

Arena1ColorsBW
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

          rem Arena 2: Battlefield (platform fighter style)
Arena2Playfield
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

Arena2ColorsColor
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

Arena2ColorsBW
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

          rem Arena 3: King of the Hill (elevated center platform)
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

Arena3ColorsColor
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

Arena3ColorsBW
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

Arena4ColorsColor
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

Arena4ColorsBW
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

Arena5ColorsColor
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

Arena5ColorsBW
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

Arena6ColorsColor
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

Arena6ColorsBW
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

Arena7ColorsColor
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

Arena7ColorsBW
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

Arena8ColorsColor
          pfcolors:
          ColPurple(2)
          ColPurple(4)
          ColPurple(4)
          ColPurple(4)
          ColPurple(4)
          ColPurple(4)
          ColPurple(4)
          ColPurple(2)
end

Arena8ColorsBW
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

          rem Arena 9: The Deep Pit (variant of Arena 1 with deeper
          rem   walls)
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

Arena9ColorsColor
          pfcolors:
          ColRed(2)
          ColRed(4)
          ColRed(4)
          ColRed(6)
          ColRed(6)
          ColRed(4)
          ColRed(4)
          ColRed(2)
end

Arena9ColorsBW
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

Arena10ColorsColor
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

Arena10ColorsBW
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

Arena11ColorsColor
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

Arena11ColorsBW
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

Arena12ColorsColor
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

Arena12ColorsBW
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

Arena13ColorsColor
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

Arena13ColorsBW
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

Arena14ColorsColor
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

Arena14ColorsBW
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

Arena15ColorsColor
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

Arena15ColorsBW
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

Arena16ColorsColor
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

Arena16ColorsBW
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

          rem ==========================================================
          rem ARENA POINTER TABLES
          rem ==========================================================
          rem Playfield pointer lookup tables for efficient arena loading
          rem Format: 32 entries (indices 0-31) for Arena1-Arena32
          rem Note: PF1 and PF2 both point to the same ArenaNPlayfield
          rem Indices 16-31 currently map to Arena1-Arena16 (for future expansion)
          rem ==========================================================

          data ArenaPF1PointerL
            <Arena1Playfield, <Arena2Playfield, <Arena3Playfield, <Arena4Playfield, <Arena5Playfield, <Arena6Playfield, <Arena7Playfield, <Arena8Playfield,
            <Arena9Playfield, <Arena10Playfield, <Arena11Playfield, <Arena12Playfield, <Arena13Playfield, <Arena14Playfield, <Arena15Playfield, <Arena16Playfield,
            <Arena1Playfield, <Arena2Playfield, <Arena3Playfield, <Arena4Playfield, <Arena5Playfield, <Arena6Playfield, <Arena7Playfield, <Arena8Playfield,
            <Arena9Playfield, <Arena10Playfield, <Arena11Playfield, <Arena12Playfield, <Arena13Playfield, <Arena14Playfield, <Arena15Playfield, <Arena16Playfield
end

          data ArenaPF1PointerH
            >Arena1Playfield, >Arena2Playfield, >Arena3Playfield, >Arena4Playfield, >Arena5Playfield, >Arena6Playfield, >Arena7Playfield, >Arena8Playfield,
            >Arena9Playfield, >Arena10Playfield, >Arena11Playfield, >Arena12Playfield, >Arena13Playfield, >Arena14Playfield, >Arena15Playfield, >Arena16Playfield,
            >Arena1Playfield, >Arena2Playfield, >Arena3Playfield, >Arena4Playfield, >Arena5Playfield, >Arena6Playfield, >Arena7Playfield, >Arena8Playfield,
            >Arena9Playfield, >Arena10Playfield, >Arena11Playfield, >Arena12Playfield, >Arena13Playfield, >Arena14Playfield, >Arena15Playfield, >Arena16Playfield
end

          data ArenaPF2PointerL
            <Arena1Playfield, <Arena2Playfield, <Arena3Playfield, <Arena4Playfield, <Arena5Playfield, <Arena6Playfield, <Arena7Playfield, <Arena8Playfield,
            <Arena9Playfield, <Arena10Playfield, <Arena11Playfield, <Arena12Playfield, <Arena13Playfield, <Arena14Playfield, <Arena15Playfield, <Arena16Playfield,
            <Arena1Playfield, <Arena2Playfield, <Arena3Playfield, <Arena4Playfield, <Arena5Playfield, <Arena6Playfield, <Arena7Playfield, <Arena8Playfield,
            <Arena9Playfield, <Arena10Playfield, <Arena11Playfield, <Arena12Playfield, <Arena13Playfield, <Arena14Playfield, <Arena15Playfield, <Arena16Playfield
end

          data ArenaPF2PointerH
            >Arena1Playfield, >Arena2Playfield, >Arena3Playfield, >Arena4Playfield, >Arena5Playfield, >Arena6Playfield, >Arena7Playfield, >Arena8Playfield,
            >Arena9Playfield, >Arena10Playfield, >Arena11Playfield, >Arena12Playfield, >Arena13Playfield, >Arena14Playfield, >Arena15Playfield, >Arena16Playfield,
            >Arena1Playfield, >Arena2Playfield, >Arena3Playfield, >Arena4Playfield, >Arena5Playfield, >Arena6Playfield, >Arena7Playfield, >Arena8Playfield,
            >Arena9Playfield, >Arena10Playfield, >Arena11Playfield, >Arena12Playfield, >Arena13Playfield, >Arena14Playfield, >Arena15Playfield, >Arena16Playfield
end

