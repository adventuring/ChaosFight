          rem ChaosFight - Source/Routines/LevelData.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem ==========================================================
          rem ARENA DATA DEFINITIONS
          rem ==========================================================
          rem 16 ARENAS inspired by classic fighting and platform games
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

pfcolors:
ColGrey(6)
ColGrey(4)
ColGrey(4)
ColGrey(2)
ColGrey(2)
ColGrey(2)
ColGrey(2)
ColGrey(2)
ColGrey(2)
ColGrey(2)
ColGrey(4)
ColGrey(6)
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
          
          pfcolors:
ColBlue(14)
ColBlue(12)
ColBlue(10)
ColBlue(8)
ColBlue(6)
ColBlue(4)
ColBlue(6)
ColBlue(8)
ColBlue(10)
ColBlue(12)
ColBlue(12)
ColBlue(14)
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
          
          pfcolors:
ColBrown(6)
ColSeafoam(4)
ColSeafoam(4)
ColSeafoam(6)
ColSeafoam(4)
ColSeafoam(4)
ColSeafoam(6)
ColSeafoam(4)
ColSeafoam(2)
ColSeafoam(4)
ColSeafoam(2)
ColBrown(6)
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
          
          pfcolors:
ColOrange(8)
ColOrange(6)
ColOrange(4)
ColOrange(4)
ColOrange(4)
ColOrange(2)
ColOrange(2)
ColOrange(2)
ColOrange(2)
ColOrange(2)
ColOrange(4)
ColOrange(6)
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
          
          pfcolors:
ColPurple(6)
ColPurple(4)
ColPurple(2)
ColPurple(0)
ColMagenta(14)
ColMagenta(12)
ColMagenta(10)
ColPurple(0)
ColPurple(2)
ColPurple(4)
ColPurple(6)
ColPurple(8)
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
          
          pfcolors:
ColBrown(8)
ColBrown(6)
ColBrown(6)
ColBrown(4)
ColBrown(4)
ColBrown(4)
ColBrown(4)
ColBrown(4)
ColBrown(4)
ColBrown(4)
ColBrown(6)
ColBrown(8)
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
          
          pfcolors:
ColRed(6)
ColRed(4)
ColRed(4)
ColRed(2)
ColPurple(2)
ColPurple(0)
ColPurple(2)
ColPurple(0)
ColPurple(2)
ColRed(2)
ColRed(4)
ColRed(6)
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
          
          pfcolors:
ColCyan(8)
ColCyan(6)
ColCyan(4)
ColCyan(2)
ColCyan(4)
ColCyan(6)
ColCyan(8)
ColCyan(10)
ColCyan(8)
ColCyan(6)
ColCyan(4)
ColCyan(6)
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
          
          pfcolors:
ColRed(8)
ColOrange(6)
ColSeafoam(6)
ColBlue(6)
ColPurple(6)
ColCyan(6)
ColGreen(6)
ColGold(6)
ColOrange(6)
ColBlue(6)
ColGreen(6)
ColRed(8)
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
          
          pfcolors:
ColGrey(8)
ColGrey(6)
ColGrey(6)
ColGrey(6)
ColGrey(4)
ColGrey(4)
ColGrey(4)
ColGrey(4)
ColGrey(4)
ColGrey(4)
ColGrey(6)
ColGrey(8)
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
          
          pfcolors:
ColGrey(6)
ColGrey(4)
ColGrey(4)
ColGrey(2)
ColGrey(2)
ColGrey(2)
ColRed(2)
ColRed(2)
ColRed(2)
ColRed(4)
ColRed(4)
ColRed(6)
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
          
          pfcolors:
ColGold(8)
ColGold(6)
ColGold(4)
ColGold(4)
ColGold(2)
ColGold(2)
ColGold(2)
ColGold(2)
ColGold(4)
ColGold(4)
ColGold(6)
ColGold(8)
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
          
          pfcolors:
ColGrey(10)
ColGrey(8)
ColGrey(8)
ColGrey(6)
ColGrey(6)
ColGrey(6)
ColGrey(6)
ColGrey(6)
ColGrey(6)
ColGrey(8)
ColGrey(8)
ColGrey(10)
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
          
          pfcolors:
ColGrey(14)
ColGrey(14)
ColGrey(12)
ColGrey(12)
ColGrey(10)
ColGrey(10)
ColGrey(8)
ColGrey(8)
ColGrey(6)
ColGrey(6)
ColGrey(4)
ColGrey(14)
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
          
          pfcolors:
ColOrange(8)
ColOrange(6)
ColOrange(4)
ColOrange(2)
ColOrange(2)
ColOrange(4)
ColOrange(6)
ColOrange(8)
ColOrange(10)
ColOrange(12)
ColOrange(14)
ColOrange(8)
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
          
          pfcolors:
ColRed(6)
ColPurple(2)
ColPurple(8)
ColCyan(4)
ColGreen(6)
ColGold(2)
ColSeafoam(8)
ColBlue(4)
ColMagenta(2)
ColOrange(6)
ColRed(4)
ColRed(6)
end
