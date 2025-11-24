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


          rem
          rem Arena Color Pointer Tables
          rem Color pointer lookup tables for efficient arena loading
          rem Format: 32 entries (indices 0-31) for Arena0-Arena31
          rem Note: All arenas reference their color tables directly.


          rem
          rem Arena Playfield Pointer Tables
          rem Playfield pointer lookup tables for efficient arena
          rem loading
          rem Format: 32 entries (indices 0-31) for Arena0-Arena31

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


