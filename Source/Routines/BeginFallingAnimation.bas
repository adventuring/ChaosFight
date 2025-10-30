          rem ChaosFight - Source/Routines/BeginFallingAnimation.bas
          rem Setup routine for Falling Animation. Sets initial state only.

BeginFallingAnimation
          dim FallFrame = a
          dim FallSpeed = b
          dim FallComplete = c
          dim ActivePlayers = d

          FallFrame = 0
          FallSpeed = 2
          FallComplete = 0
          ActivePlayers = 2

          COLUBK = ColGray(0)

          return


