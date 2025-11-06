          rem ChaosFight - Source/Routines/LevelData.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem ==========================================================
          rem ARENA DATA DEFINITIONS
          rem ==========================================================
          rem 32 ARENAS inspired by classic fighting and platform games
          rem Playfields are 16 pixels wide (LEFT HALF ONLY - right
          rem   mirrors)
          rem X = wall/platform, . = empty space

          rem Inspirations:
          rem - Mario Bros (arcade): Multi-tier platforms
          rem - Joust: High platforms, open vertical space
          rem - Super Smash Bros: Varied platform configurations
          rem - Mortal Kombat: Flat arenas with obstacles
          rem ==========================================================

          rem ==========================================================
          rem ARENA DATA
          rem ==========================================================

Arena1Data
          rem Arena 1: THE PIT (Mortal Kombat - flat arena with walls)
          rem Result: Walls on sides, open flat floor
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
          XXXXXXXXXXXXXXXX
end
Arena2Data
          playfield:
          XXXXXXXXXXXXXXXX
          X...............
          X...............
          X...............
          X...............
          X..........XXXXX : rem Left half of centered platform - mirrors to full platform
          X...............
          X...............
          X...............
          X...............
          X...............
          XXXXXXXXXXXXXXXX
end
Arena3Data
          playfield:
          XXXXXXXXXXXXXXXX
          X...............
          X...............
          X......XXXXXXXXX
          X...............
          X...............
          X.......XXXXXXXX
          X...............
          X...............
          X........XXXXXXX
          X...............
          XXXXXXXXXXXXXXXX
end
Arena4Data
          playfield:
          XXXXXXXXXXXXXXXX
          X...............
          XX..............
          XX..............
          XX..............
          X...............
          X...............
          X...............
          X...............
          X...............
          X...............
          XXXXXXXXXXXXXXXX
end
Arena5Data
          playfield:
          XXXXXXXXXXXXXXXX
          X...............
          X...............
          X...............
          X...............
          X...............
          X..XXXXXXXXXXXXX
          X...............
          X...............
          X...............
          X...............
          XXXXXXXXXXXXXXXX
end
Arena6Data
          playfield:
          XXXXXXXXXXXXXXXX
          X...............
          X...............
          X...............
          XXXX............
          X...............
          X...............
          X...............
          XXXXXX..........
          X...............
          X...............
          XXXXXXXXXXXXXXXX
end
Arena7Data
          playfield:
          XXXXXXXXXXXXXXXX
          X...............
          XX..............
          X...............
          X........XXX....
          X...............
          X..XX...........
          X...............
          X...........XX..
          X...............
          X...............
          XXXXXXXXXXXXXXXX
end
Arena8Data
          playfield:
          XXXXXXXXXXXXXXXX
          X...............
          X...............
          X...............
          X...............
          X........XXX....
          X.......XXXX....
          X.......XXXX....
          X...............
          X...............
          X...............
          XXXXXXXXXXXXXXXX
end
Arena9Data
          playfield:
          XXXXXXXXXXXXXXXX
          X...............
          X...............
          X.XX............
          X...............
          X.......XXXXXXXX
          X...............
          X..XX...........
          X...............
          X...............
          X...............
          XXXXXXXXXXXXXXXX
end
Arena10Data
          playfield:
          XXXXXXXXXXXXXXXX
          X...............
          X.XX............
          X..XX...........
          X...XX..........
          X....XX.........
          X.....XX........
          X......XX.......
          X.......XXXXXXXX
          XXXXXXXXXXXXXXXX
end
Arena11Data
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
          XXXXX...........
end
Arena12Data
          playfield:
          XXXXXXXXXXXXXXXX
          X...............
          X...............
          X.XX............
          X...............
          X...XX..........
          X...............
          X.XX............
          X...............
          X...............
          X...............
          XXXXXXXXXXXXXXXX
end
Arena13Data
          playfield:
          XXXXXXXXXXXXXXXX
          X...............
          X...............
          X...............
          XXX.............
          X...............
          X...............
          X...............
          XXX.............
          X...............
          X...............
          XXXXXXXXXXXXXXXX
end
Arena14Data
          playfield:
          XXXXXXXXXXXXXXXX
          X...............
          X...............
          X...............
          X.XX............
          X..XXX...........
          X...XXXX........
          X....XXXXX.......
          X.....XXXXXX.....
          X......XXXXXXX...
          X.......XXXXXXXX
          XXXXXXXXXXXXXXXX
end
Arena15Data
          playfield:
          XXXXXXXXXXXXXXXX
          X...............
          X...............
          X...............
          X...............
          XXXXXXX.........
          XXXXXXX.........
          X...............
          X...............
          X...............
          X...............
          XXXXXXXXXXXXXXXX
end
Arena16Data
          playfield:
          XXXXXXXXXXXXXXXX
          X...............
          X.XX............
          X...............
          X..........XXX..
          X...............
          X...XX..........
          X...............
          X...........XX..
          X...............
          X.XXX...........
          XXXXXXXXXXXXXXXX
end
Arena0Data
          rem Arena 0: Flat arena
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
Arena17Data
          rem The Spire (vertical tower platforms)
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
Arena18Data
          rem The Bridge (wide center platform)
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
Arena19Data
          rem The Pits (narrow platforms with gaps)
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
Arena20Data
          rem The Stairs (stepped platforms)
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
Arena21Data
          rem The Grid (checkerboard pattern)
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
Arena22Data
          rem The Columns (vertical pillars)
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
Arena23Data
          rem The Waves (curved platforms)
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
Arena24Data
          rem The Cross (cross-shaped platform)
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
Arena25Data
          rem The Maze (complex wall pattern)
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
Arena26Data
          rem The Islands (scattered platforms)
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
Arena27Data
          rem The Rings (concentric platforms)
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
Arena28Data
          rem The Slopes (diagonal platforms)
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
Arena29Data
          rem The Zigzag (zigzag pattern)
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
Arena30Data
          rem The Ladder (vertical rungs)
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
Arena31Data
          rem The Final Battle (complex multi-platform)
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





          data Arena0DataColors
          ColOrange(2),
          ColOrange(4),
          ColOrange(6),
          ColOrange(8),
          ColOrange(10),
          ColOrange(12),
          ColOrange(14),
          ColOrange(0)
end

          data Arena17DataColors
          ColLime(2),
          ColLime(4),
          ColLime(6),
          ColLime(4),
          ColLime(6),
          ColLime(4),
          ColLime(2),
          ColLime(8)
end

          data Arena18DataColors
          ColTeal(12),
          ColTeal(12),
          ColTeal(12),
          ColTeal(14),
          ColTeal(14),
          ColTeal(12),
          ColTeal(12),
          ColTeal(12)
end

          data Arena19DataColors
          ColMaroon(2),
          ColMaroon(2),
          ColMaroon(0),
          ColMaroon(2),
          ColMaroon(2),
          ColMaroon(0),
          ColMaroon(2),
          ColMaroon(4)
end

          data Arena20DataColors
          ColNavy(4),
          ColNavy(4),
          ColNavy(4),
          ColNavy(6),
          ColNavy(6),
          ColNavy(8),
          ColNavy(8),
          ColNavy(2)
end

          data Arena21DataColors
          ColOlive(4),
          ColOlive(4),
          ColOlive(6),
          ColOlive(6),
          ColOlive(4),
          ColOlive(4),
          ColOlive(6),
          ColOlive(6)
end

          data Arena22DataColors
          ColCrimson(4),
          ColCrimson(4),
          ColCrimson(4),
          ColCrimson(4),
          ColCrimson(4),
          ColCrimson(4),
          ColCrimson(4),
          ColCrimson(6)
end

          data Arena23DataColors
          ColAqua(2),
          ColAqua(4),
          ColAqua(4),
          ColAqua(2),
          ColAqua(4),
          ColAqua(4),
          ColAqua(2),
          ColAqua(6)
end

          data Arena24DataColors
          ColSlate(4),
          ColSlate(4),
          ColSlate(4),
          ColSlate(6),
          ColSlate(6),
          ColSlate(4),
          ColSlate(4),
          ColSlate(4)
end

          data Arena25DataColors
          ColViolet(2),
          ColViolet(4),
          ColViolet(6),
          ColViolet(8),
          ColViolet(8),
          ColViolet(6),
          ColViolet(4),
          ColViolet(2)
end

          data Arena26DataColors
          ColCoral(2),
          ColCoral(2),
          ColCoral(0),
          ColCoral(4),
          ColCoral(4),
          ColCoral(0),
          ColCoral(2),
          ColCoral(2)
end

          data Arena27DataColors
          ColAmber(2),
          ColAmber(4),
          ColAmber(6),
          ColAmber(8),
          ColAmber(8),
          ColAmber(6),
          ColAmber(4),
          ColAmber(2)
end

          data Arena28DataColors
          ColEmerald(2),
          ColEmerald(4),
          ColEmerald(6),
          ColEmerald(8),
          ColEmerald(8),
          ColEmerald(6),
          ColEmerald(4),
          ColEmerald(2)
end

          data Arena29DataColors
          ColRose(2),
          ColRose(4),
          ColRose(6),
          ColRose(4),
          ColRose(4),
          ColRose(6),
          ColRose(4),
          ColRose(2)
end

          data Arena30DataColors
          ColMint(4),
          ColMint(4),
          ColMint(4),
          ColMint(4),
          ColMint(4),
          ColMint(4),
          ColMint(4),
          ColMint(6)
end

          data Arena31DataColors
          ColPlatinum(2),
          ColPlatinum(4),
          ColPlatinum(4),
          ColPlatinum(6),
          ColPlatinum(4),
          ColPlatinum(4),
          ColPlatinum(6),
          ColPlatinum(8)
end

          data Arena1DataColors
                    ColGrey(6),
          ColGrey(4),
          ColGrey(4),
          ColGrey(2),
          ColGrey(2),
          ColGrey(2),
          ColGrey(2),
          ColGrey(2),
          ColGrey(2),
          ColGrey(2),
          ColGrey(4),
          ColGrey(6)
end




          data Arena2DataColors
                    ColBlue(14),
          ColBlue(12),
          ColBlue(10),
          ColBlue(8),
          ColBlue(6),
          ColBlue(4),
          ColBlue(6),
          ColBlue(8),
          ColBlue(10),
          ColBlue(12),
          ColBlue(12),
          ColBlue(14)
end


          data Arena3DataColors
                    ColBrown(6),
          ColSeafoam(4),
          ColSeafoam(4),
          ColSeafoam(6),
          ColSeafoam(4),
          ColSeafoam(4),
          ColSeafoam(6),
          ColSeafoam(4),
          ColSeafoam(2),
          ColSeafoam(4),
          ColSeafoam(2),
          ColBrown(6)
end


          data Arena4DataColors
                    ColOrange(8),
          ColOrange(6),
          ColOrange(4),
          ColOrange(4),
          ColOrange(4),
          ColOrange(2),
          ColOrange(2),
          ColOrange(2),
          ColOrange(2),
          ColOrange(2),
          ColOrange(4),
          ColOrange(6)
end


          data Arena5DataColors
                    ColPurple(6),
          ColPurple(4),
          ColPurple(2),
          ColPurple(0),
          ColMagenta(14),
          ColMagenta(12),
          ColMagenta(10),
          ColPurple(0),
          ColPurple(2),
          ColPurple(4),
          ColPurple(6),
          ColPurple(8)
end


          data Arena6DataColors
                    ColBrown(8),
          ColBrown(6),
          ColBrown(6),
          ColBrown(4),
          ColBrown(4),
          ColBrown(4),
          ColBrown(4),
          ColBrown(4),
          ColBrown(4),
          ColBrown(4),
          ColBrown(6),
          ColBrown(8)
end


          data Arena7DataColors
                    ColRed(6),
          ColRed(4),
          ColRed(4),
          ColRed(2),
          ColPurple(2),
          ColPurple(0),
          ColPurple(2),
          ColPurple(0),
          ColPurple(2),
          ColRed(2),
          ColRed(4),
          ColRed(6)
end


          data Arena8DataColors
                    ColCyan(8),
          ColCyan(6),
          ColCyan(4),
          ColCyan(2),
          ColCyan(4),
          ColCyan(6),
          ColCyan(8),
          ColCyan(10),
          ColCyan(8),
          ColCyan(6),
          ColCyan(4),
          ColCyan(6)
end


          data Arena9DataColors
                    ColRed(8),
          ColOrange(6),
          ColSeafoam(6),
          ColBlue(6),
          ColPurple(6),
          ColCyan(6),
          ColGreen(6),
          ColGold(6),
          ColOrange(6),
          ColBlue(6),
          ColGreen(6),
          ColRed(8)
end


          data Arena10DataColors
                    ColGrey(8),
          ColGrey(6),
          ColGrey(6),
          ColGrey(6),
          ColGrey(4),
          ColGrey(4),
          ColGrey(4),
          ColGrey(4),
          ColGrey(4),
          ColGrey(4),
          ColGrey(6),
          ColGrey(8)
end


          data Arena11DataColors
                    ColGrey(6),
          ColGrey(4),
          ColGrey(4),
          ColGrey(2),
          ColGrey(2),
          ColGrey(2),
          ColRed(2),
          ColRed(2),
          ColRed(2),
          ColRed(4),
          ColRed(4),
          ColRed(6)
end


          data Arena12DataColors
                    ColGold(8),
          ColGold(6),
          ColGold(4),
          ColGold(4),
          ColGold(2),
          ColGold(2),
          ColGold(2),
          ColGold(2),
          ColGold(4),
          ColGold(4),
          ColGold(6),
          ColGold(8)
end


          data Arena13DataColors
                    ColGrey(10),
          ColGrey(8),
          ColGrey(8),
          ColGrey(6),
          ColGrey(6),
          ColGrey(6),
          ColGrey(6),
          ColGrey(6),
          ColGrey(6),
          ColGrey(8),
          ColGrey(8),
          ColGrey(10)
end


          data Arena14DataColors
                    ColGrey(14),
          ColGrey(14),
          ColGrey(12),
          ColGrey(12),
          ColGrey(10),
          ColGrey(10),
          ColGrey(8),
          ColGrey(8),
          ColGrey(6),
          ColGrey(6),
          ColGrey(4),
          ColGrey(14)
end


          data Arena15DataColors
                    ColOrange(8),
          ColOrange(6),
          ColOrange(4),
          ColOrange(2),
          ColOrange(2),
          ColOrange(4),
          ColOrange(6),
          ColOrange(8),
          ColOrange(10),
          ColOrange(12),
          ColOrange(14),
          ColOrange(8)
end


          data Arena16DataColors
                    ColRed(6),
          ColPurple(2),
          ColPurple(8),
          ColCyan(4),
          ColGreen(6),
          ColGold(2),
          ColSeafoam(8),
          ColBlue(4),
          ColMagenta(2),
          ColOrange(6),
          ColRed(4),
          ColRed(6)
end
