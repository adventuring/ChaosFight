          rem ChaosFight - Source/Routines/SetPlayerSprites.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

SetPlayerSprites
          rem Returns: Far (return otherbank)
          asm
SetPlayerSprites

end
          rem
          rem Returns: Far (return otherbank)
          rem Set Player Sprites
          rem Sets colors and graphics for all player sprites.
          rem Colors depend on hurt and guard state only (player-index palettes).
          rem Sets colors and graphics for all player sprites with hurt
          rem state and facing direction handling
          rem
          rem Input: playerCharacter[] (global array) = character types,
          rem playerRecoveryFrames[] (global array) = recovery frame
          rem counts, playerState[] (global array) = player states,
          rem controllerStatus (global) = controller state,
          rem playerHealth[] (global array) = player
          rem health, currentCharacter (global) = character index for
          rem sprite loading
          rem
          rem Output: All player sprite colors and graphics set, sprite
          rem reflections set based on facing direction
          rem
          rem Mutates: temp1-temp3 (color parameter packing), COLUP0,
          rem COLUP1, COLUP2, COLUP3 (TIA registers) = player colors,
          rem REFP0 (TIA register) = player 0 reflection, _NUSIZ1,
          rem NewNUSIZ+2, NewNUSIZ+3 (TIA registers) = player sprite
          rem reflections, player sprite pointers (via
          rem LoadCharacterSprite), currentPlayer + temp2-temp3 (LoadCharacterColors parameters) = color
          rem loading parameters (hurt flag, guard flag)
          rem
          rem Called Routines: LoadCharacterColors (bank14) - loads
          rem player colors, LoadCharacterSprite (bank10) - loads sprite
          rem graphics
          rem
          rem Constraints: Multisprite kernel requires _COLUP1 and
          rem _NUSIZ1 for Player 2 virtual sprite. Players 3/4 only
          rem rendered if Quadtari detected and selected
          rem Set Player 1 color and sprite
          rem Use LoadCharacterColors for consistent color handling
          rem Player index
          rem Hurt flag (non-zero = recovering)
          let currentPlayer = 0
          rem Guard flag (non-zero = guarding)
          let temp2 = playerRecoveryFrames[0]
          let temp3 = playerState[0] & PlayerStateBitGuarding
          gosub LoadCharacterColors bank14
          COLUP0 = temp6
Player1ColorDone

          rem Set sprite reflection based on facing direction (bit 3:
          rem   0=left, 1=right) - matches REFP0 bit 3 for direct copy
          asm
            lda playerState
            and #PlayerStateBitFacing
            sta REFP0

end

          rem Load sprite data from character definition
          let currentCharacter = playerCharacter[0]
          rem Animation frame (0 = idle)
          let temp2 = 0
          rem Animation action (0 = idle)
          let temp3 = 0
          gosub LoadCharacterSprite bank16

          rem Set Player 2 color and sprite
          rem Use LoadCharacterColors for consistent color handling
          rem NOTE: Multi-sprite kernel requires _COLUP1 (with
          rem Player index
          rem Hurt flag (non-zero = recovering)
          let currentPlayer = 1
          rem Guard flag (non-zero = guarding)
          let temp2 = playerRecoveryFrames[1]
          let temp3 = playerState[1] & PlayerStateBitGuarding
          gosub LoadCharacterColors bank14
          _COLUP1 = temp6

Player2ColorDone

          rem Set sprite reflection based on facing direction
          rem NOTE: Multi-sprite kernel requires _NUSIZ1 (not NewNUSIZ+1)
          rem   for Player 2 virtual sprite
          rem NUSIZ reflection uses bit 6 - preserve other bits (size,
          rem   etc.)
          asm
          lda _NUSIZ1
          and #NUSIZMaskReflection
          sta _NUSIZ1
          lda playerState+1
          and #PlayerStateBitFacing
          beq .Player2ReflectionDone
          lda _NUSIZ1
          ora #PlayerStateBitFacingNUSIZ
          sta _NUSIZ1
.Player2ReflectionDone

end

          rem Load sprite data from character definition
          let currentCharacter = playerCharacter[1]
          rem Animation frame (0 = idle)
          let temp2 = 0
          rem Animation action (0 = idle)
          let temp3 = 0
          gosub LoadCharacterSprite bank16

          rem Set colors for Players 3 & 4 (multisprite kernel)
          rem Players 3 & 4 have independent COLUP2/COLUP3 registers
          rem No color inheritance issues with proper multisprite
          rem   implementation

          rem Set Player 3 color and sprite (if active)

          if (controllerStatus & SetQuadtariDetected) = 0 then goto DonePlayer3Sprite
          if playerCharacter[2] = NoCharacter then goto DonePlayer3Sprite
          if ! playerHealth[2] then goto DonePlayer3Sprite

          rem Use LoadCharacterColors for consistent color handling
          rem Player index
          rem Hurt flag (non-zero = recovering)
          let currentPlayer = 2
          rem Guard flag (non-zero = guarding)
          let temp2 = playerRecoveryFrames[2]
          let temp3 = playerState[2] & PlayerStateBitGuarding
          gosub LoadCharacterColors bank14
          rem fall through to Player3ColorDone
          COLUP2 = temp6

Player3ColorDone

          rem Set sprite reflection based on facing direction
          rem NUSIZ reflection uses bit 6 - preserve other bits (size,
          rem   etc.)
          asm
            lda NewNUSIZ+2
            and #NUSIZMaskReflection
            sta NewNUSIZ+2
            lda playerState+2
            and #PlayerStateBitFacing
            beq .Player3ReflectionDone
            lda NewNUSIZ+2
            ora #PlayerStateBitFacingNUSIZ
            sta NewNUSIZ+2
.Player3ReflectionDone

end

          rem Load sprite data from character definition
          let currentCharacter = playerCharacter[2]
          rem Animation frame (0 = idle)
          let temp2 = 0
          rem Animation action (0 = idle)
          let temp3 = 0
          gosub LoadCharacterSprite bank16

DonePlayer3Sprite

          rem Set Player 4 color and sprite (if active)

          if (controllerStatus & SetQuadtariDetected) = 0 then goto DonePlayer4Sprite
          if playerCharacter[3] = NoCharacter then goto DonePlayer4Sprite
          if ! playerHealth[3] then goto DonePlayer4Sprite

          rem Use LoadCharacterColors for consistent color handling
          rem Player 4: Turquoise (player index color), hurt handled by
          rem Player index
          rem Hurt flag (non-zero = recovering)
          let currentPlayer = 3
          rem Guard flag (non-zero = guarding)
          let temp2 = playerRecoveryFrames[3]
          let temp3 = playerState[3] & PlayerStateBitGuarding
          gosub LoadCharacterColors bank14
          COLUP3 = temp6

Player4ColorDone

          rem Set sprite reflection based on facing direction
          rem NUSIZ reflection uses bit 6 - preserve other bits (size,
          rem   etc.)
          asm
            lda NewNUSIZ+3
            and # NUSIZMaskReflection
            sta NewNUSIZ+3
            lda playerState+3
            and # PlayerStateBitFacing
            beq .Player4ReflectionDone
            lda NewNUSIZ+3
            ora #PlayerStateBitFacingNUSIZ
            sta NewNUSIZ+3
.Player4ReflectionDone

end

          rem Load sprite data from character definition
          let currentCharacter = playerCharacter[3]
          rem Animation frame (0 = idle)
          let temp2 = 0
          rem Animation action (0 = idle)
          let temp3 = 0
          gosub LoadCharacterSprite bank16

DonePlayer4Sprite

          return thisbank
