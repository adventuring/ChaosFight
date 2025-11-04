          rem ChaosFight - Source/Routines/LevelData.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

#include "Source/Common/Colors.h"

          rem =================================================================
          rem LEVEL DATA DEFINITIONS
          rem =================================================================
          rem 16 ARENAS inspired by classic fighting and platform games
          rem Playfields are 16 pixels wide (LEFT HALF ONLY - right mirrors)
          rem X = wall/platform, . = empty space

          rem Inspirations:
          rem - Mario Bros (arcade): Multi-tier platforms
          rem - Joust: High platforms, open vertical space
          rem - Super Smash Bros: Varied platform configurations
          rem - Mortal Kombat: Flat arenas with obstacles
          rem =================================================================

          rem =================================================================
          rem LEVEL DATA
          rem =================================================================

Level1Data
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

Level2Data
          rem Arena 2: BATTLEFIELD (Smash Bros - centered main platform)
          rem Result: High centered platform (left half - mirrors to full width)
          playfield:
          XXXXXXXXXXXXXXXX
          X...............
          X...............
          X...............
          X...............
          X..........XXXXX  rem Left half of centered platform - mirrors to full platform
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

Level3Data
          rem Arena 3: MARIO SEWERS (Mario Bros - three tier platforms)
          rem Result: Three descending centered platforms
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

Level4Data
          rem Arena 4: JOUST PEAKS (Joust - high side platforms)
          rem Result: Tall platforms on left and right edges
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

Level5Data
          rem Arena 5: FINAL DESTINATION (Smash Bros - wide centered platform)
          rem Result: Single wide high platform
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

Level6Data
          rem Arena 6: PIPELINE (Mario Bros - left side ledges)
          rem Result: Ledges starting from left edge at different heights (left half - mirrors to full width)
          playfield:
          XXXXXXXXXXXXXXXX
          X...............
          X...............
          X...............
          XXXX............
          rem Left edge ledge - mirrors to create left and right ledges
          X...............
          X...............
          X...............
          XXXXXX..........
          rem Lower left edge ledge - mirrors to create left and right ledges
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

Level7Data
          rem Arena 7: DRAGON TOWER (Joust - asymmetric staggered platforms)
          rem Result: Small platforms scattered at different heights
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

Level8Data
          rem Arena 8: FOUNTAIN (Mortal Kombat - center obstacle)
          rem Result: Centered raised block
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

Level9Data
          rem Arena 9: RAINBOW ROAD (Smash Bros - scattered platforms)
          rem Result: Multiple small platforms at various heights
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

Level10Data
          rem Arena 10: STAIRWAY (Mario Bros - ascending stairs)
          rem Result: Diagonal staircase from bottom-left to top-right (left half - mirrors to full width)
          rem Stairs start from left edge and progress rightward
          playfield:
          XXXXXXXXXXXXXXXX
          X...............
          rem Left wall on all rows
          X.XX............
          rem First step (left edge)
          X..XX...........
          rem Second step
          X...XX..........
          rem Third step
          X....XX.........
          rem Fourth step
          X.....XX........
          rem Fifth step
          X......XX.......
          rem Sixth step
          X.......XXXXXXXX
          rem Bottom floor - mirrors to full width floor
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

Level11Data
          rem Arena 11: BRIDGE GAP (Mortal Kombat - broken floor with pit)
          rem Result: Floor only on left edge (left half - mirrors to floors on both edges)
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
          rem Left edge floor - mirrors to create floor on both left and right edges with center pit
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

Level12Data
          rem Arena 12: TEMPLE (Smash Bros - multiple small platforms)
          rem Result: Grid of small platforms starting from left edge (left half - mirrors to full width)
          playfield:
          XXXXXXXXXXXXXXXX
          X...............
          X...............
          X.XX............
          rem Left-side platform - mirrors to create left and right platforms
          X...............
          X...XX..........
          rem Left-side platform at different position - mirrors to create symmetric platforms
          X...............
          X.XX............
          rem Left-side platform - mirrors to create left and right platforms
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

Level13Data
          rem Arena 13: CASTLE WALLS (Elevated corner platforms)
          rem Result: Raised platforms starting from left edge (left half - mirrors to corner platforms)
          playfield:
          XXXXXXXXXXXXXXXX
          X...............
          X...............
          X...............
          XXX.............
          rem Left edge upper platform - mirrors to create upper left and right corner platforms
          X...............
          X...............
          X...............
          XXX.............
          rem Left edge lower platform - mirrors to create lower left and right corner platforms
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

Level14Data
          rem Arena 14: SUMMIT (Joust - pyramid mountain)
          rem Result: Pyramid shape starting from left edge (left half - mirrors to symmetric pyramid)
          playfield:
          XXXXXXXXXXXXXXXX
          X...............
          X...............
          X...............
          X.XX............
          rem Pyramid base row - mirrors to create symmetric pyramid base
          X..XXX...........
          rem Pyramid second row - mirrors to create symmetric pyramid
          X...XXXX........
          rem Pyramid third row - mirrors to create symmetric pyramid
          X....XXXXX.......
          rem Pyramid fourth row - mirrors to create symmetric pyramid
          X.....XXXXXX.....
          rem Pyramid fifth row - mirrors to create symmetric pyramid
          X......XXXXXXX...
          rem Pyramid sixth row - mirrors to create symmetric pyramid
          X.......XXXXXXXX
          rem Bottom floor - mirrors to full width floor
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

Level15Data
          rem Arena 15: HAZARD ZONE (Split level with ledge)
          rem Result: High ledge starting from left edge (left half - mirrors to create ledges on both sides)
          playfield:
          XXXXXXXXXXXXXXXX
          X...............
          X...............
          X...............
          X...............
          XXXXXXX.........
          rem Left edge upper ledge - mirrors to create ledges on both left and right edges
          XXXXXXX.........
          rem Left edge upper ledge continuation
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

Level16Data
          rem Arena 16: CHAOS ARENA (Complex multi-level asymmetric)
          rem Result: Scattered platforms starting from left edge at multiple heights (left half - mirrors to full width)
          playfield:
          XXXXXXXXXXXXXXXX
          X...............
          X.XX............
          rem Left-side upper platform - mirrors to create symmetric platforms
          X...............
          X..........XXX..
          rem Right-side upper platform - mirrors to create symmetric platforms
          X...............
          X...XX..........
          rem Left-side middle platform - mirrors to create symmetric platforms
          X...............
          X...........XX..
          rem Right-side lower platform - mirrors to create symmetric platforms
          X...............
          X.XXX...........
          rem Left-side lower platform - mirrors to create symmetric platforms
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
