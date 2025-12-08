;;; ChaosFight - Source/Routines/PlayerPlayfieldCollisions.bas

;;; Copyright © 2025 Bruce-Robert Pocock.



CheckPlayfieldCollisionAllDirections
          ;; Returns: Far (return otherbank)


;; CheckPlayfieldCollisionAllDirections (duplicate)


          ;; Check Playfield Collision All Directions
          ;; Returns: Far (return otherbank)

          ;; Checks for playfield pixel collisions in all four directions and blocks movement by zeroing velocity.

          ;; Uses CharacterHeights table for proper hitbox detection.

          ;;
          ;; Input: ;; TODO: Convert assignment: currentPlayer = player index (0-3)


          ;; playerX[], playerY[], playerCharacter[]

          ;; playerVelocityX[], playerVelocityY[], playerVelocityXL[], playerVelocityYL[]

          ;; playerSubpixelX[], playerSubpixelY[], playerSubpixelXL[], playerSubpixelYL[]

          ;; CharacterHeights[], ScreenInsetX, pfrowheight, pfrows

          ;;
          ;; Output: Player velocities zeroed when collisions detected

          ;;
          ;; Mutates: temp2-temp6, playfieldRow, playfieldColumn, rowCounter,

          ;; playerVelocityX[], playerVelocityY[],

          ;; playerVelocityXL[], playerVelocityYL[],

          ;; playerSubpixelX[], playerSubpixelY[],

          ;; playerSubpixelXL[], playerSubpixelYL[]

          ;;
          ;; Called Routines: PlayfieldRead (bank16)

          ;;
          ;; Constraints: Checks collisions at head, middle, and feet positions.

                    ;; let ;; TODO: Convert assignment: temp2 = playerX[currentPlayer]          lda currentPlayer          asl          tax          lda playerX,x          sta temp2


          ;; let ;; TODO: Convert assignment: temp3 = playerY[currentPlayer]

          lda currentPlayer
          asl
          tax
          ;; lda playerY,x (duplicate)
          sta temp3

          ;; let ;; TODO: Convert assignment: temp4 = playerCharacter[currentPlayer]

          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta temp4 (duplicate)

                    ;; let ;; TODO: Convert assignment: temp5 = CharacterHeights[temp4]

          ;; lda temp4 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterHeights,x (duplicate)
          ;; sta temp5 / 16 (duplicate)
          ;; lda temp4 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterHeights,x (duplicate)
          ;; sta temp5 (duplicate)

          ;; ;; let ;; TODO: Convert assignment: temp6 = temp2 - ScreenInsetX          lda temp2          sec          sbc ScreenInsetX          sta temp6

          ;; lda temp2 (duplicate)
          sec
          sbc ScreenInsetX
          ;; sta temp6 (duplicate)

          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc ScreenInsetX (duplicate)
          ;; sta temp6 (duplicate)


          ;; ;; let ;; TODO: Convert assignment: temp6 = temp6 / 4          lda temp6          lsr          lsr          sta temp6

          ;; lda temp6 (duplicate)
          lsr
          ;; lsr (duplicate)
          ;; sta temp6 (duplicate)

          ;; lda temp6 (duplicate)
          ;; lsr (duplicate)
          ;; lsr (duplicate)
          ;; sta temp6 (duplicate)


                    ;; if temp6 & $80 then let ;; TODO: Convert assignment: temp6 = 0

          ;; lda temp6 (duplicate)
          cmp # 32
          bcc skip_9653
          ;; lda # 31 (duplicate)
          ;; sta temp6 (duplicate)
skip_9653:




                    ;; let ;; TODO: Convert assignment: playfieldRow = temp3 / 16


          ;;           ;; if playfieldRow >= pfrows then let
          ;; lda playfieldRow (duplicate)
          ;; cmp pfrows (duplicate)
          ;; bcc skip_7030 (duplicate)
          let_label:

          jmp let_label
skip_7030: lda pfrows
 ;; sec (duplicate)
 ;; sbc #1 (duplicate)
 ;; sta playfieldRow (duplicate)


;; lda pfrows (duplicate)

          ;; sec (duplicate)

;; sbc 1 (duplicate)

;; sta playfieldRow (duplicate)


                    ;; if playfieldRow & $80 then let ;; TODO: Convert assignment: playfieldRow = 0

          ;; lda playfieldRow (duplicate)
          and #$80
          beq skip_6159
          ;; lda # 0 (duplicate)
          ;; sta playfieldRow (duplicate)
skip_6159:
          ;; lda temp6 (duplicate)
          ;; cmp # 0 (duplicate)
          bne skip_4423
          ;; jmp PFCheckRight (duplicate)
skip_4423:




          ;; lda temp6 (duplicate)
          ;; sec (duplicate)
          ;; sbc # 1 (duplicate)
          ;; sta temp1 (duplicate)

          ;; lda # 0 (duplicate)
          ;; sta temp3 (duplicate)

          ;; Cross-bank call to PF_ProcessHorizontalCollision in bank 10
          ;; lda # >(return_point_1_L184-1) (duplicate)
          pha
          ;; lda # <(return_point_1_L184-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PF_ProcessHorizontalCollision-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PF_ProcessHorizontalCollision-1) (duplicate)
          ;; pha (duplicate)
                    ldx # 9
          ;; jmp BS_jsr (duplicate)
return_point_1_L184:





PFCheckRight .proc
          ;; Returns: Far (return otherbank)

          ;; if temp6 >= 31 then goto PFCheckUp
          ;; lda temp6 (duplicate)
          ;; cmp 31 (duplicate)

          ;; bcc skip_4136 (duplicate)

          ;; jmp skip_4136 (duplicate)

          skip_4136:



          ;; lda temp6 (duplicate)
          clc
          adc # 4
          ;; sta temp1 (duplicate)

          ;; lda # 1 (duplicate)
          ;; sta temp3 (duplicate)

          ;; Cross-bank call to PF_ProcessHorizontalCollision in bank 10
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PF_ProcessHorizontalCollision-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PF_ProcessHorizontalCollision-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 9 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)




.pend

PFCheckUp .proc
          ;; Returns: Far (return otherbank)

          ;; lda playfieldRow (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_6982 (duplicate)
          ;; jmp PFCheckDown_Body (duplicate)
skip_6982:




          ;; lda playfieldRow (duplicate)
          ;; sec (duplicate)
          ;; sbc # 1 (duplicate)
          ;; sta rowCounter (duplicate)

          ;; lda rowCounter (duplicate)
          ;; sta temp2 (duplicate)

          ;; Cross-bank call to PF_CheckRowColumns in bank 10
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PF_CheckRowColumns-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PF_CheckRowColumns-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 9 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


                    ;; if temp4 then goto PFBlockUp
          ;; lda temp4 (duplicate)
          ;; beq skip_8518 (duplicate)
          ;; jmp PFBlockUp (duplicate)
skip_8518:

          ;; jmp PFCheckDown_Body (duplicate)



.pend

PFBlockUp .proc

          ;; Skip zeroing velocity for Radish Goblin (bounce system handles it)
          ;; Returns: Far (return otherbank)

                    ;; if playerCharacter[currentPlayer] = CharacterRadishGoblin then goto PFBlockUpClamp

                    ;; if playerVelocityY[currentPlayer] & $80 then let playerVelocityY[currentPlayer] = 0 : let playerVelocityYL[currentPlayer] = 0
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerVelocityY,x (duplicate)
          ;; and #$80 (duplicate)
          ;; beq skip_6900 (duplicate)
          ;; lda # 0 (duplicate)
          ;; sta playerVelocityY,x (duplicate)
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda # 0 (duplicate)
          ;; sta playerVelocityYL,x (duplicate)
skip_6900:

.pend

PFBlockUpClamp .proc
          ;; lda playfieldRow (duplicate)
          ;; clc (duplicate)
          ;; adc # 1 (duplicate)
          ;; sta rowYPosition (duplicate)

                    ;; let ;; TODO: Convert assignment: rowYPosition = rowYPosition * 16


                    ;; if playerY[currentPlayer] < rowYPosition then let playerY[currentPlayer] = rowYPosition
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; cmp rowYPosition (duplicate)
          bcs skip_254
          ;; lda rowYPosition (duplicate)
          ;; sta playerY,x (duplicate)
skip_254:

                    ;; if playerY[currentPlayer] < rowYPosition then let playerSubpixelY_W[currentPlayer] = rowYPosition
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; cmp rowYPosition (duplicate)
          ;; bcs skip_1234 (duplicate)
          ;; lda rowYPosition (duplicate)
          ;; sta playerSubpixelY_W,x (duplicate)
skip_1234:

                    ;; if playerY[currentPlayer] < rowYPosition then let playerSubpixelY_WL[currentPlayer] = 0
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; cmp rowYPosition (duplicate)
          ;; bcs skip_4354 (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerSubpixelY_WL,x (duplicate)
skip_4354:

.pend

PFBlockDown .proc

          ;; Skip zeroing velocity for Radish Goblin (bounce system handles it)
          ;; Returns: Far (return otherbank)
          jsr BS_return

                    ;; if playerVelocityY[currentPlayer] > 0 then let playerVelocityY[currentPlayer] = 0 : let playerVelocityYL[currentPlayer] = 0
          ;; jsr BS_return (duplicate)

.pend

PF_CheckColumnSpan .proc


          ;; Helper: sample a column at up to three row offsets (top/mid/bottom)
          ;; Returns: Far (return otherbank)

          ;; Input: playfieldColumn (global), playfieldRow (global top row), ;; TODO: Convert assignment: temp3 = row span


          ;; Output: ;; TODO: Convert assignment: temp4 = 1 if any solid pixel encountered


          ;; TODO: dim ;; TODO: Convert assignment: PCC_rowSpan = temp3


          ;; TODO: dim ;; TODO: Convert assignment: PCC_result = temp4


          ;; lda # 0 (duplicate)
          ;; sta PCC_result (duplicate)

          ;; lda playfieldRow (duplicate)
          ;; sta rowCounter (duplicate)

          ;; lda # 0 (duplicate)
          ;; sta temp3 (duplicate)

.pend

PFCS_SampleLoop .proc

                    ;; if rowCounter & $80 then goto PFCS_Advance

          ;; if rowCounter >= pfrows then goto PFCS_Advance
          ;; lda rowCounter (duplicate)
          ;; cmp pfrows (duplicate)
          ;; bcc skip_5083 (duplicate)
          ;; jmp (duplicate)
skip_5083:


          label_unknown:

          ;; lda playfieldColumn (duplicate)
          ;; sta temp1 (duplicate)

          ;; lda rowCounter (duplicate)
          ;; sta temp2 (duplicate)

          ;; Cross-bank call to PlayfieldRead in bank 16
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 15 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


                    ;; if temp1 then let ;; TODO: Convert assignment: PCC_result = 1 : goto PFCS_Done          lda temp1          beq skip_351

skip_351:
          ;; jmp skip_351 (duplicate)

.pend

PFCS_Advance .proc

          inc temp3

          ;; if temp3 >= 3 then goto PFCS_Done
          ;; lda temp3 (duplicate)
          ;; cmp 3 (duplicate)

          ;; bcc skip_4503 (duplicate)

          ;; jmp skip_4503 (duplicate)

          skip_4503:

          ;; lda PCC_rowSpan (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_8939 (duplicate)
          ;; jmp PFCS_Done (duplicate)
skip_8939:


                    ;; let ;; TODO: Convert assignment: rowCounter = rowCounter + PCC_rowSpan

          ;; jmp PFCS_SampleLoop (duplicate)



PFCS_Done
          ;; Returns: Far (return otherbank)

          ;; lda PCC_result (duplicate)
          ;; sta temp4 (duplicate)

          ;; jsr BS_return (duplicate)

.pend

PF_CheckRowColumns .proc


          ;; Helper: test current row for center/side collisions
          ;; Returns: Far (return otherbank)

          ;; Input: ;; TODO: Convert assignment: temp2 = row index, temp6 = center column


          ;; Output: ;; TODO: Convert assignment: temp4 = 1 if any column collides


          ;; dim ;; TODO: Convert assignment: PRC_rowIndex = temp2 (dim removed - variable definitions handled elsewhere)


          ;; TODO: dim ;; TODO: Convert assignment: PRC_result = temp4


          ;; lda # 0 (duplicate)
          ;; sta PRC_result (duplicate)

          ;; jsr BS_return (duplicate)

          ;; jsr BS_return (duplicate)



          ;; lda temp6 (duplicate)
          ;; sta temp1 (duplicate)

          ;; lda PRC_rowIndex (duplicate)
          ;; sta temp2 (duplicate)

          ;; Cross-bank call to PlayfieldRead in bank 16
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 15 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


                    ;; if temp1 then let ;; TODO: Convert assignment: PRC_result = 1 : goto PRC_Done          lda temp1          beq skip_6294

skip_6294:
          ;; jmp skip_6294 (duplicate)
          ;; lda temp6 (duplicate)
          ;; cmp # 1 (duplicate)
          ;; bcc skip_549 (duplicate)
skip_549:


          ;; jmp PRC_CheckRight (duplicate)

.pend

PRC_CheckLeft .proc

          ;; lda temp6 (duplicate)
          ;; sec (duplicate)
          ;; sbc # 1 (duplicate)
          ;; sta temp1 (duplicate)

          ;; lda PRC_rowIndex (duplicate)
          ;; sta temp2 (duplicate)

          ;; Cross-bank call to PlayfieldRead in bank 16
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 15 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


                    ;; if temp1 then let ;; TODO: Convert assignment: PRC_result = 1 : goto PRC_Done          lda temp1          beq skip_6294

;; skip_6294: (duplicate)
          ;; jmp skip_6294 (duplicate)

.pend

PRC_CheckRight .proc

          ;; if temp6 >= 31 then goto PRC_Done
          ;; lda temp6 (duplicate)
          ;; cmp 31 (duplicate)

          ;; bcc skip_2626 (duplicate)

          ;; jmp skip_2626 (duplicate)

          skip_2626:

          ;; lda temp6 (duplicate)
          ;; clc (duplicate)
          ;; adc # 1 (duplicate)
          ;; sta temp1 (duplicate)

          ;; lda PRC_rowIndex (duplicate)
          ;; sta temp2 (duplicate)

          ;; Cross-bank call to PlayfieldRead in bank 16
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 15 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


                    ;; if temp1 then let ;; TODO: Convert assignment: PRC_result = 1          lda temp1          beq skip_3174

skip_3174:
          ;; jmp skip_3174 (duplicate)

PRC_Done
          ;; lda PRC_result (duplicate)
          ;; sta temp4 (duplicate)

          ;; jsr BS_return (duplicate)

PF_ProcessHorizontalCollision
          ;; Returns: Far (return otherbank)


;; PF_ProcessHorizontalCollision (duplicate)


          ;; Helper: evaluate horizontal collision for given column and clamp
          ;; Returns: Far (return otherbank)

          ;; Input: ;; TODO: Convert assignment: temp1 = column index, temp3 = direction (0=left, 1=right)


          ;; TODO: dim ;; TODO: Convert assignment: PHC_column = temp1


          ;; TODO: dim ;; TODO: Convert assignment: PHC_direction = temp3


          ;; jsr BS_return (duplicate)

          ;; jsr BS_return (duplicate)



          ;; lda PHC_column (duplicate)
          ;; sta playfieldColumn (duplicate)

          ;; lda temp5 (duplicate)
          ;; sta temp3 (duplicate)

          ;; Cross-bank call to PF_CheckColumnSpan in bank 10
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PF_CheckColumnSpan-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PF_CheckColumnSpan-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 9 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; jsr BS_return (duplicate)



          ;; lda currentPlayer (duplicate)
          ;; sta temp1 (duplicate)

                    ;; if playerCharacter[temp1] = CharacterRadishGoblin then goto PHC_ClampOnly

                    ;; if PHC_direction then goto PHC_CheckRightVelocity
          ;; lda PHC_direction (duplicate)
          ;; beq skip_3527 (duplicate)
          ;; jmp PHC_CheckRightVelocity (duplicate)
skip_3527:

                    ;; if playerVelocityX[temp1] & $80 then let playerVelocityX[temp1] = 0 : let playerVelocityXL[temp1] = 0
          ;; jmp PHC_ClampOnly (duplicate)

.pend

PHC_CheckRightVelocity .proc

                    ;; if playerVelocityX[temp1] > 0 then let playerVelocityX[temp1] = 0 : let playerVelocityXL[temp1] = 0

PHC_ClampOnly
          ;; lda temp6 (duplicate)
          ;; sta rowYPosition (duplicate)

                    ;; if PHC_direction then goto PHC_ClampRight
          ;; lda PHC_direction (duplicate)
          ;; beq skip_5775 (duplicate)
          ;; jmp PHC_ClampRight (duplicate)
skip_5775:

          ;; inc rowYPosition (duplicate)

                    ;; let ;; TODO: Convert assignment: rowYPosition = rowYPosition * 4


                    ;; let ;; TODO: Convert assignment: rowYPosition = rowYPosition + ScreenInsetX

          ;; lda rowYPosition (duplicate)
          ;; clc (duplicate)
          ;; adc ScreenInsetX (duplicate)
          ;; sta rowYPosition (duplicate)

                    ;; if playerX[temp1] < rowYPosition then let playerX[temp1] = rowYPosition
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerX,x (duplicate)
          ;; cmp rowYPosition (duplicate)
          ;; bcs skip_7094 (duplicate)
          ;; lda rowYPosition (duplicate)
          ;; sta playerX,x (duplicate)
skip_7094:

                    ;; if playerX[temp1] < rowYPosition then let playerSubpixelX_W[temp1] = rowYPosition
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerX,x (duplicate)
          ;; cmp rowYPosition (duplicate)
          ;; bcs skip_7776 (duplicate)
          ;; lda rowYPosition (duplicate)
          ;; sta playerSubpixelX_W,x (duplicate)
skip_7776:

                    ;; if playerX[temp1] < rowYPosition then let playerSubpixelX_WL[temp1] = 0
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerX,x (duplicate)
          ;; cmp rowYPosition (duplicate)
          ;; bcs skip_945 (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerSubpixelX_WL,x (duplicate)
skip_945:
          ;; jsr BS_return (duplicate)

.pend

PHC_ClampRight .proc

          dec rowYPosition

                    ;; let ;; TODO: Convert assignment: rowYPosition = rowYPosition * 4


                    ;; let ;; TODO: Convert assignment: rowYPosition = rowYPosition + ScreenInsetX

          ;; lda rowYPosition (duplicate)
          ;; clc (duplicate)
          ;; adc ScreenInsetX (duplicate)
          ;; sta rowYPosition (duplicate)

                    ;; if playerX[temp1] > rowYPosition then let playerX[temp1] = rowYPosition
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerX,x (duplicate)
          ;; sec (duplicate)
          ;; sbc rowYPosition (duplicate)
          ;; bcc skip_9821 (duplicate)
          ;; beq skip_9821 (duplicate)
          ;; lda rowYPosition (duplicate)
          ;; sta playerX,x (duplicate)
skip_9821:

                    ;; if playerX[temp1] > rowYPosition then let playerSubpixelX_W[temp1] = rowYPosition
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerX,x (duplicate)
          ;; sec (duplicate)
          ;; sbc rowYPosition (duplicate)
          ;; bcc skip_6112 (duplicate)
          ;; beq skip_6112 (duplicate)
          ;; lda rowYPosition (duplicate)
          ;; sta playerSubpixelX_W,x (duplicate)
skip_6112:

                    ;; if playerX[temp1] > rowYPosition then let playerSubpixelX_WL[temp1] = 0
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerX,x (duplicate)
          ;; sec (duplicate)
          ;; sbc rowYPosition (duplicate)
          ;; bcc skip_61 (duplicate)
          ;; beq skip_61 (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda # 0 (duplicate)
          ;; sta playerSubpixelX_WL,x (duplicate)
skip_61:
          ;; jsr BS_return (duplicate)

.pend

PFCheckDown_Body .proc

                    ;; let ;; TODO: Convert assignment: rowCounter = playfieldRow + temp5

          ;; jsr BS_return (duplicate)



          ;; lda rowCounter (duplicate)
          ;; clc (duplicate)
          ;; adc # 1 (duplicate)
          ;; sta playfieldRow (duplicate)

          ;; jsr BS_return (duplicate)



          ;; lda playfieldRow (duplicate)
          ;; sta temp2 (duplicate)

          ;; Cross-bank call to PF_CheckRowColumns in bank 10
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PF_CheckRowColumns-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PF_CheckRowColumns-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 9 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


                    ;; if temp4 then goto PFBlockDown
          ;; lda temp4 (duplicate)
          ;; beq skip_5737 (duplicate)
          ;; jmp PFBlockDown (duplicate)
skip_5737:

          ;; jsr BS_return (duplicate)



.pend

