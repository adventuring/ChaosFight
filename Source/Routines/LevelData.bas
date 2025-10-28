          rem ChaosFight - Source/Routines/LevelData.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

#include "Source/Common/Colors.h"

          rem =================================================================
          rem LEVEL DATA DEFINITIONS
          rem =================================================================
          rem 16 ARENAS inspired by classic fighting and platform games
          rem Playfields are 16 pixels wide (LEFT HALF ONLY - right mirrors)
          rem X = wall/platform, . = empty space
          rem
          rem Inspirations:
          rem - Mario Bros (arcade): Multi-tier platforms
          rem - Joust: High platforms, open vertical space
          rem - Super Smash Bros: Varied platform configurations
          rem - Mortal Kombat: Flat arenas with obstacles
          rem =================================================================

          rem =================================================================
          rem LEVEL LOADING DISPATCH
          rem =================================================================

Level1Data
          gosub LoadLevelFromFile1
          return

Level2Data
          gosub LoadLevelFromFile2
          return

Level3Data
          gosub LoadLevelFromFile3
          return

Level4Data
          gosub LoadLevelFromFile4
          return

Level5Data
          gosub LoadLevelFromFile5
          return

Level6Data
          gosub LoadLevelFromFile6
          return

Level7Data
          gosub LoadLevelFromFile7
          return

Level8Data
          gosub LoadLevelFromFile8
          return

Level9Data
          gosub LoadLevelFromFile9
          return

Level10Data
          gosub LoadLevelFromFile10
          return

Level11Data
          gosub LoadLevelFromFile11
          return

Level12Data
          gosub LoadLevelFromFile12
          return

Level13Data
          gosub LoadLevelFromFile13
          return

Level14Data
          gosub LoadLevelFromFile14
          return

Level15Data
          gosub LoadLevelFromFile15
          return

Level16Data
          gosub LoadLevelFromFile16
          return

          rem =================================================================
          rem INDIVIDUAL LEVEL LOADERS
          rem =================================================================

LoadLevelFromFile1
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
          return

LoadLevelFromFile2
          rem Arena 2: BATTLEFIELD (Smash Bros - centered main platform)
          rem Result: High centered platform
          playfield:
          XXXXXXXXXXXXXXXX
          X...............
          X...............
          X...............
          X...............
          X.......XXXXXXXX
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
          return

LoadLevelFromFile3
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
          return

LoadLevelFromFile4
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
          return

LoadLevelFromFile5
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
          return

LoadLevelFromFile6
          rem Arena 6: PIPELINE (Mario Bros - left side ledges)
          rem Result: Left and right ledges at different heights
          playfield:
          XXXXXXXXXXXXXXXX
          X...............
          X...............
          X...............
          XXXX............
          X...............
          X...............
          X...............
          XXXX............
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
          return

LoadLevelFromFile7
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
          return

LoadLevelFromFile8
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
          return

LoadLevelFromFile9
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
          return

LoadLevelFromFile10
          rem Arena 10: STAIRWAY (Mario Bros - ascending stairs)
          rem Result: Diagonal staircase from bottom-left to top-right
          playfield:
          XXXXXXXXXXXXXXXX
          X...............
          X...............
          XX..............
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
          return

LoadLevelFromFile11
          rem Arena 11: BRIDGE GAP (Mortal Kombat - broken floor with pit)
          rem Result: Floor only on outer edges, pit in center
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
          return

LoadLevelFromFile12
          rem Arena 12: TEMPLE (Smash Bros - multiple small platforms)
          rem Result: Grid of small platforms
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
          return

LoadLevelFromFile13
          rem Arena 13: CASTLE WALLS (Elevated corner platforms)
          rem Result: Raised platforms in corners
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
          return

LoadLevelFromFile14
          rem Arena 14: SUMMIT (Joust - pyramid mountain)
          rem Result: Centered pyramid shape
          playfield:
          XXXXXXXXXXXXXXXX
          X...............
          X...............
          X...............
          X........XXX....
          X.......XXXX....
          X......XXXXX....
          X.....XXXXXX....
          X....XXXXXXX....
          X...XXXXXXXX....
          X..XXXXXXXXX....
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
          return

LoadLevelFromFile15
          rem Arena 15: HAZARD ZONE (Split level with ledge)
          rem Result: High ledge on left side
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
          return

LoadLevelFromFile16
          rem Arena 16: CHAOS ARENA (Complex multi-level asymmetric)
          rem Result: Scattered platforms at multiple heights
          playfield:
          XXXXXXXXXXXXXXXX
          X...............
          X.XX............
          X...............
          X........XXX....
          X...............
          X...XX..........
          X...............
          X..........XX...
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
          return
