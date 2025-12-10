;;; ChaosFight - Source/Routines/CheckPlayerCollision.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

XDistanceDone:
          ;; X distance calculated - check for collision
          ;; Returns: Near (return thisbank)
          ;;
          ;; Input: temp6 = absolute X distance
          ;;
          ;; Output: temp3 = 1 if X collision, 0 if not
          ;;
          ;; Mutates: temp3
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: None
          ;;
          if temp6 >= PlayerSpriteWidth then NoCollision
          cmp # PlayerSpriteWidth
          bcc XDistanceCheckCollision

          lda # 0
          sta temp3
          jmp CPC_Done

XDistanceCheckCollision:
          lda # 1
          sta temp3
          ;;
          ;; Check Y collision
          if temp3 == 0 then CPC_Done
          lda temp3
          cmp # 0
          beq CPC_Done

          ;;
          ;; Load player Y positions into temporaries
          ;; let temp4 = playerY[temp1]
          lda temp1
          asl
          tax
          lda playerY,x
          sta temp4
          ;; let temp5 = playerY[temp2]
          lda temp2
          asl
          tax
          lda playerY,x
          sta temp5
          ;;
          ;; Calculate Y distance
          if temp4 >= temp5 then CPC_CalcYDistance
          lda temp4
          cmp temp5
          bcc YDistanceCalcRight

          jmp CPC_CalcYDistance

YDistanceCalcRight:
          ;; let temp6 = temp5 - temp4
          lda temp5
          sec
          sbc temp4
          sta temp6
          jmp YDistanceDone

CPC_CalcYDistance:
          ;; Returns: Near (return thisbank)
          ;; Calculate Y distance (temp4 - temp5)
          ;; Returns: Near (return thisbank)
          ;;
          ;; Input: temp4, temp5
          ;;
          ;; Output: temp6 = absolute Y distance
          ;;
          ;; Mutates: temp6
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: None
          ;;
          ;; let temp6 = temp4 - temp5
          lda temp4
          sec
          sbc temp5
          sta temp6
          jmp YDistanceDone

YDistanceDone:
          ;; Returns: Near (return thisbank)
          ;; Y distance calculated - check for collision
          ;; Returns: Near (return thisbank)
          ;;
          ;; Input: temp6 = absolute Y distance
          ;;
          ;; Output: temp3 = 1 if Y collision, 0 if not
          ;;
          ;; Mutates: temp3
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: None
          ;;
          if temp6 >= CharacterHeights[playerCharacter[temp1]] then NoCollision
          lda temp1
          asl
          tax
          lda playerCharacter,x
          asl
          tax
          lda CharacterHeights,x
          cmp temp6
          bcs YDistanceCheckCollision

          lda # 0
          sta temp3
          jmp CPC_Done

YDistanceCheckCollision:
          lda # 1
          sta temp3

CPC_Done:
          ;; Returns: Near (return thisbank)
          ;; Collision check complete - return result in temp3
          ;; Returns: Far (return otherbank)
          rts

CheckPlayerCollision:
          ;;
          ;; Collision Detection With Subpixel Precision
          ;; Check collision between two players using integer
          ;; positions
          ;;
          ;; Input: temp1 = player 1 index → temp1
          ;; temp2 = player 2 index → temp2
          ;;
          ;; Output: temp3 = 1 if collision, 0 if not →
          ;; temp3
          ;; NOTE: Uses integer positions only (subpixel ignored for
          ;; collision)
          ;;
          MUTATES:
          ;; temp3 = temp3 (return value: 1 if collision, 0 if not)
          ;; temp4-temp13 = Used internally for calculations
          ;; WARNING: Callers should read temp3 immediately; helper mutates temps for calculations.
          ;;
          ;; Input: temp1 = player 1 index (0-3), temp2 = player 2
          ;; index (0-3), playerX[], playerY[] (global arrays) = player
          ;; positions, playerCharacter[] (global array) = character types,
          ;; CharacterHeights[] (global data table) = character heights
          ;;
          ;; Output: temp3 = 1 if collision, 0 if not
          ;;
          ;; Mutates: temp3-temp6 (used for calculations, temp4-5
          ;; reused after X/Y checks)
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Uses integer positions only (subpixel ignored
          ;; for collision). Checks × collision (16 pixel width) and Y
          ;; collision (using CharacterHeights table). WARNING: temp3 is mutated during the routine; callers must read it immediately.
          ;; Uses temp1-temp6 (temp4-5 reused after X/Y checks)

          ;; Load player X positions into temporaries
          ;; let temp4 = playerX[temp1]
          lda temp1
          asl
          tax
          lda playerX,x
          sta temp4
          ;; let temp5 = playerX[temp2]
          lda temp2
          asl
          tax
          lda playerX,x
          sta temp5

          ;; Calculate absolute × distance between players
          if temp4 >= temp5 then CalcXDistanceRight

          ;; let temp6 = temp5 - temp4
          lda temp5
          sec
          sbc temp4
          sta temp6

          jmp XDistanceDone

CalcXDistanceRight .proc
          ;; let temp6 = temp4 - temp5
          lda temp4
          sec
          sbc temp5
          sta temp6

          ;; Calculate X distance (temp4 - temp5)
          lda temp4
          sec
          sbc temp5
          sta temp6
          jmp XDistanceDone

.pend

CalcYDistanceDown .proc
          ;; Fetch character half-height values using shared SCRAM scratch variables
          ;; let characterIndex = playerCharacter[temp1]
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta characterIndex
          ;; Use bit shift instead of division (optimized for Atari 2600)
          ;; let characterHeight = CharacterHeights[characterIndex]
          lda characterIndex
          asl
          tax
          lda CharacterHeights,x
          sta characterHeight
            lda characterHeight
            lsr
            sta halfHeight1

          ;; let characterIndex = playerCharacter[temp2]
          lda temp2
          asl
          tax
          lda playerCharacter,x
          sta characterIndex
          ;; Use bit shift instead of division (optimized for Atari 2600)
          ;; let characterHeight = CharacterHeights[characterIndex]
          lda characterIndex
          asl
          tax
          lda CharacterHeights,x
          sta characterHeight
          lda characterIndex
          asl
          tax
          lda CharacterHeights,x
          sta characterHeight
            lda characterHeight
            lsr
            sta halfHeight2

          ;; Compute absolute Y distance between player centers
                    if temp4 >= temp5 then CalcYDistanceDown

          ;; let temp6 = temp5 - temp4          lda temp5          sec          sbc temp4          sta temp6
          lda temp5
          sec
          sbc temp4
          sta temp6

          lda temp5
          sec
          sbc temp4
          sta temp6

          jmp YDistanceDone

.pend

