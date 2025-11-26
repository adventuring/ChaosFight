          rem ChaosFight - Source/Routines/RestoreNormalPlayerColor.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

RestoreNormalPlayerColor
          rem Provide shared entry point for restoring normal player colors
          rem after guard tinting. Color reload executed by rendering code.
          rem
          rem Input: temp1 = player index (0-3)
          rem
          rem Output: None
          rem
          rem Mutates: temp4 (loads character index for downstream routines)
          let temp4 = playerCharacter[temp1]
          return thisbank
