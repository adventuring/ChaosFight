          rem ChaosFight - Source/Routines/LoadCharacterColors.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Player color loading function - colors are player-specific, not character-specific

LoadCharacterColors
          asm
LoadCharacterColors

end
          rem Load player colors based on guard and hurt state.
          rem Player colors are fixed per player index:
          rem   Player 0 → Indigo, Player 1 → Red, Player 2 → Yellow, Player 3 → Turquoise.
          rem Guarding always forces light cyan, regardless of TV mode.
          rem Hurt state dims to luminance 6 (PlayerColors6) except SECAM, which uses magenta.
          rem Color/B&W switch and pause overrides do not affect player colors.
          rem
          rem Input: currentPlayer (global) = player index (0-3)
          rem        temp2 = hurt state flag (0 = normal, non-zero = hurt/recovering)
          rem        temp3 = guard state flag (0 = normal, non-zero = guarding)
          rem
          rem Output: temp6 = resulting color value for the active TV build
          rem
          rem Mutates: temp6 only (output)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must remain in bank14 (called from SetPlayerSprites bank2)

          rem Guard state takes priority over hurt state
          if temp3 then let temp6 = ColCyan(12) : return otherbank

          rem Hurt state handling
          if !temp2 then goto NormalColorState
          rem Hurt state - SECAM uses magenta, others use dimmed colors
#ifdef TV_SECAM
          let temp6 = ColMagenta(12)
#else
          let temp6 = PlayerColors6[currentPlayer]
#endif
          return otherbank

NormalColorState
          rem Normal color state
          let temp6 = PlayerColors12[currentPlayer]
          return otherbank

