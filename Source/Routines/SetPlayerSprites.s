;;; ChaosFight - Source/Routines/SetPlayerSprites.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


SetPlayerSprites .proc
          ;;
          ;; Returns: Far (return otherbank)
          ;; Set Player Sprites
          ;; Sets colors and graphics for all player sprites.
          ;; Colors depend on hurt and guard state only (player-index palettes).
          ;; Sets colors and graphics for all player sprites with hurt
          ;; state and facing direction handling
          ;;
          ;; Input: playerCharacter[] (global array) = character types,
          ;; playerRecoveryFrames[] (global array) = recovery frame
          ;; counts, playerState[] (global array) = player sta

          ;; controllerStatus (global) = controller sta

          ;; playerHealth[] (global array) = player
          ;; health, currentCharacter (global) = character index for
          ;; sprite loading
          ;;
          ;; Output: All player sprite colors and graphics set, sprite
          ;; reflections set based on facing direction
          ;;
          ;; Mutates: temp1-temp3 (color parameter packing), COLUP0,
          ;; COLUP1, COLUP2, COLUP3 (TIA registers) = player colors,
          ;; REFP0 (TIA register) = player 0 reflection, _NUSIZ1,
          ;; NewNUSIZ+2, NewNUSIZ+3 (TIA registers) = player sprite
          ;; reflections, player sprite pointers (via
          ;; LoadCharacterSprite), currentPlayer + temp2-temp3 (LoadCharacterColors parameters) = color
          ;; loading parameters (hurt flag, guard flag)
          ;;
          ;; Called Routines: LoadCharacterColors (bank14) - loads
          ;; player colors, LoadCharacterSprite (bank10) - loads sprite
          ;; graphics
          ;;
          ;; Constraints: Multisprite kernel requires _COLUP1 and
          ;; _NUSIZ1 for Player 2 virtual sprite. Players 3/4 only
          ;; rendered if Quadtari detected and selected
          ;; Set Player 1 color and sprite
          ;; Use LoadCharacterColors for consistent color handling
          ;; Player index
          ;; Hurt flag (non-zero = recovering)
          lda # 0
          sta currentPlayer
          ;; Guard flag (non-zero = guarding)
          ;; let temp2 = playerRecoveryFrames[0]
          lda # 0
          asl
          tax
          lda playerRecoveryFrames,x
          sta temp2
          ;; let temp3 = playerState[0]
          lda # 0
          asl
          tax
          lda playerState,x
          sta temp3
          and # PlayerStateBitGuarding
          sta temp3
          lda # 0
          asl
          tax
          lda playerState,x
          sta temp3
          ;; Cross-bank call to LoadCharacterColors in bank 14
          lda # >(AfterLoadCharacterColorsP0-1)
          pha
          lda # <(AfterLoadCharacterColorsP0-1)
          pha
          lda # >(LoadCharacterColors-1)
          pha
          lda # <(LoadCharacterColors-1)
          pha
          ldx # 13
          jmp BS_jsr

AfterLoadCharacterColorsP0:

          COLUP0 = temp6

Player1ColorDone:

          ;; Set sprite reflection based on facing direction (bit 3:
          ;; 0=left, 1=right) - matches REFP0 bit 3 for direct copy
          lda playerState
          and # PlayerStateBitFacing
          sta REFP0

          ;; Load sprite data from character definition
          ;; let currentCharacter = playerCharacter[0]         
          lda # 0
          asl
          tax
          lda playerCharacter,x
          sta currentCharacter
          ;; Animation frame (0 = idle)
          lda # 0
          sta temp2
          ;; Animation action (0 = idle)
          lda # 0
          sta temp3
          ;; Cross-bank call to LoadCharacterSprite in bank 16
          lda # >(AfterLoadCharacterSpriteP0-1)
          pha
          lda # <(AfterLoadCharacterSpriteP0-1)
          pha
          lda # >(LoadCharacterSprite-1)
          pha
          lda # <(LoadCharacterSprite-1)
          pha
          ldx # 15
          jmp BS_jsr

AfterLoadCharacterSpriteP0:

          ;; Set Player 2 color and sprite
          ;; Use LoadCharacterColors for consistent color handling
          ;; NOTE: Multi-sprite kernel requires _COLUP1 (with
          ;; Player index
          ;; Hurt flag (non-zero = recovering)
          lda # 1
          sta currentPlayer
          ;; Guard flag (non-zero = guarding)
          ;; let temp2 = playerRecoveryFrames[1]
          lda # 1
          asl
          tax
          lda playerRecoveryFrames,x
          sta temp2
          ;; let temp3 = playerState[1]
          lda # 1
          asl
          tax
          lda playerState,x
          sta temp3
          and # PlayerStateBitGuarding
          sta temp3
          lda # 1
          asl
          tax
          lda playerState,x
          sta temp3
          ;; Cross-bank call to LoadCharacterColors in bank 14
          lda # >(AfterLoadCharacterColorsP1-1)
          pha
          lda # <(AfterLoadCharacterColorsP1-1)
          pha
          lda # >(LoadCharacterColors-1)
          pha
          lda # <(LoadCharacterColors-1)
          pha
          ldx # 13
          jmp BS_jsr
AfterLoadCharacterColorsP1:

          _COLUP1 = temp6

Player2ColorDone

          ;; Set sprite reflection based on facing direction
          ;; NOTE: Multi-sprite kernel requires _NUSIZ1 (not NewNUSIZ+1)
          ;; for Player 2 virtual sprite
          ;; NUSIZ reflection uses bit 6 - preserve other bits (size,
          ;; etc.)
          lda NewNUSIZ
          and # NUSIZMaskReflection
          sta NewNUSIZ
          lda playerState+1
          and # PlayerStateBitFacing
          beq Player2ReflectionDone
          lda NewNUSIZ
          ora # PlayerStateBitFacingNUSIZ
          sta NewNUSIZ
Player2ReflectionDone:



          ;; Load sprite data from character definition
          ;; let currentCharacter = playerCharacter[1]         
          lda 1
          asl
          tax
          lda playerCharacter,x
          sta currentCharacter
          ;; Animation frame (0 = idle)
          lda # 0
          sta temp2
          ;; Animation action (0 = idle)
          lda # 0
          sta temp3
          ;; Cross-bank call to LoadCharacterSprite in bank 16
          lda # >(AfterLoadCharacterSpriteP1-1)
          pha
          lda # <(AfterLoadCharacterSpriteP1-1)
          pha
          lda # >(LoadCharacterSprite-1)
          pha
          lda # <(LoadCharacterSprite-1)
          pha
                    ldx # 15
          jmp BS_jsr
AfterLoadCharacterSpriteP1:


          ;; Set colors for Players 3 & 4 (multisprite kernel)
          ;; Players 3 & 4 have independent COLUP2/COLUP3 registers
          ;; No color inheritance issues with proper multisprite
          ;; implementation

          ;; Set Player 3 color and sprite (if active)

          lda controllerStatus
          and # SetQuadtariDetected
          cmp # 0
          bne CheckPlayer3Health
          jmp DonePlayer3Sprite
CheckPlayer3Health:

          ;; if playerCharacter[2] = NoCharacter then goto DonePlayer3Sprite
          ;; if ! playerHealth[2] then goto DonePlayer3Sprite
          lda 2
          asl
          tax
          lda playerHealth,x
          bne CheckPlayer3HealthThreshold
          jmp DonePlayer3Sprite
CheckPlayer3HealthThreshold:

          lda 2
          asl
          tax
          lda playerHealth,x
          bne SetPlayer3Color
          jmp DonePlayer3Sprite
SetPlayer3Color:



          ;; Use LoadCharacterColors for consistent color handling
          ;; Player index
          ;; Hurt flag (non-zero = recovering)
          lda # 2
          sta currentPlayer
          ;; Guard flag (non-zero = guarding)
          ;; let temp2 = playerRecoveryFrames[2]
          lda # 2
          asl
          tax
          lda playerRecoveryFrames,x
          sta temp2
          ;; let temp3 = playerState[2]
          lda 2
          asl
          tax
          lda playerState,x
          sta temp3 & PlayerStateBitGuarding
          lda 2
          asl
          tax
          lda playerState,x
          sta temp3
          ;; Cross-bank call to LoadCharacterColors in bank 14
          lda # >(AfterLoadCharacterColorsP3-1)
          pha
          lda # <(AfterLoadCharacterColorsP3-1)
          pha
          lda # >(LoadCharacterColors-1)
          pha
          lda # <(LoadCharacterColors-1)
          pha
                    ldx # 13
          jmp BS_jsr
AfterLoadCharacterColorsP3:

          ;; fall through to Player3ColorDone
          COLUP2 = temp6

Player3ColorDone

          ;; Set sprite reflection based on facing direction
          ;; NUSIZ reflection uses bit 6 - preserve other bits (size,
          ;; etc.)
            lda NewNUSIZ+2
            and # NUSIZMaskReflection
            sta NewNUSIZ+2
            lda playerState+2
            and # PlayerStateBitFacing
            beq Player3ReflectionDone
            lda NewNUSIZ+2
            ora # PlayerStateBitFacingNUSIZ
            sta NewNUSIZ+2
Player3ReflectionDone:



          ;; Load sprite data from character definition
          ;; let currentCharacter = playerCharacter[2]         
          lda 2
          asl
          tax
          lda playerCharacter,x
          sta currentCharacter
          ;; Animation frame (0 = idle)
          lda # 0
          sta temp2
          ;; Animation action (0 = idle)
          lda # 0
          sta temp3
          ;; Cross-bank call to LoadCharacterSprite in bank 16
          lda # >(AfterLoadCharacterSpriteP3-1)
          pha
          lda # <(AfterLoadCharacterSpriteP3-1)
          pha
          lda # >(LoadCharacterSprite-1)
          pha
          lda # <(LoadCharacterSprite-1)
          pha
                    ldx # 15
          jmp BS_jsr
AfterLoadCharacterSpriteP3:


DonePlayer3Sprite

          ;; Set Player 4 color and sprite (if active)

          lda controllerStatus
          and # SetQuadtariDetected
          cmp # 0
          bne CheckPlayer4Health
          jmp DonePlayer4Sprite
CheckPlayer4Health:

          ;; if playerCharacter[3] = NoCharacter then goto DonePlayer4Sprite
          ;; if ! playerHealth[3] then goto DonePlayer4Sprite
          lda 3
          asl
          tax
          lda playerHealth,x
          bne CheckPlayer4HealthThreshold
          jmp DonePlayer4Sprite
CheckPlayer4HealthThreshold:

          lda 3
          asl
          tax
          lda playerHealth,x
          bne SetPlayer4Color
          jmp DonePlayer4Sprite
SetPlayer4Color:



          ;; Use LoadCharacterColors for consistent color handling
          ;; Player 4: Turquoise (player index color), hurt handled by
          ;; Player index
          ;; Hurt flag (non-zero = recovering)
          lda # 3
          sta currentPlayer
          ;; Guard flag (non-zero = guarding)
          ;; let temp2 = playerRecoveryFrames[3]
          lda # 3
          asl
          tax
          lda playerRecoveryFrames,x
          sta temp2
          ;; let temp3 = playerState[3]
          lda 3
          asl
          tax
          lda playerState,x
          sta temp3 & PlayerStateBitGuarding
          lda 3
          asl
          tax
          lda playerState,x
          sta temp3
          ;; Cross-bank call to LoadCharacterColors in bank 14
          lda # >(AfterLoadCharacterColorsP4-1)
          pha
          lda # <(AfterLoadCharacterColorsP4-1)
          pha
          lda # >(LoadCharacterColors-1)
          pha
          lda # <(LoadCharacterColors-1)
          pha
                    ldx # 13
          jmp BS_jsr
AfterLoadCharacterColorsP4:

          COLUP3 = temp6

Player4ColorDone

          ;; Set sprite reflection based on facing direction
          ;; NUSIZ reflection uses bit 6 - preserve other bits (size,
          ;; etc.)
            lda NewNUSIZ+3
            and # NUSIZMaskReflection
            sta NewNUSIZ+3
            lda playerState+3
            and # PlayerStateBitFacing
            beq Player4ReflectionDone
            lda NewNUSIZ+3
            ora # PlayerStateBitFacingNUSIZ
            sta NewNUSIZ+3
Player4ReflectionDone:



          ;; Load sprite data from character definition
          ;; let currentCharacter = playerCharacter[3]         
          lda 3
          asl
          tax
          lda playerCharacter,x
          sta currentCharacter
          ;; Animation frame (0 = idle)
          lda # 0
          sta temp2
          ;; Animation action (0 = idle)
          lda # 0
          sta temp3
          ;; Cross-bank call to LoadCharacterSprite in bank 16
          lda # >(AfterLoadCharacterSpriteP4-1)
          pha
          lda # <(AfterLoadCharacterSpriteP4-1)
          pha
          lda # >(LoadCharacterSprite-1)
          pha
          lda # <(LoadCharacterSprite-1)
          pha
                    ldx # 15
          jmp BS_jsr
AfterLoadCharacterSpriteP4:


DonePlayer4Sprite

          jmp BS_return

.pend

