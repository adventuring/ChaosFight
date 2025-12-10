;;; ChaosFight - Source/Routines/PlayerPlayfieldCollisions.bas

;;; Copyright © 2025 Bruce-Robert Pocock.



CheckPlayfieldCollisionAllDirections
          ;; Returns: Far (return otherbank)


CheckPlayfieldCollisionAllDirections


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

                    let ;; TODO: Convert assignment: temp2 = playerX[currentPlayer]          lda currentPlayer          asl          tax          lda playerX,x          sta temp2


          let ;; TODO: Convert assignment: temp3 = playerY[currentPlayer]

          lda currentPlayer
          asl
          tax
          lda playerY,x
          sta temp3

          let ;; TODO: Convert assignment: temp4 = playerCharacter[currentPlayer]

          lda currentPlayer
          asl
          tax
          lda playerCharacter,x
          sta temp4

                    let ;; TODO: Convert assignment: temp5 = CharacterHeights[temp4]

          lda temp4
          asl
          tax
          lda CharacterHeights,x
          sta temp5 / 16
          lda temp4
          asl
          tax
          lda CharacterHeights,x
          sta temp5

          ;; let ;; TODO: Convert assignment: temp6 = temp2 - ScreenInsetX          lda temp2          sec          sbc ScreenInsetX          sta temp6

          lda temp2
          sec
          sbc ScreenInsetX
          sta temp6

          lda temp2
          sec
          sbc ScreenInsetX
          sta temp6


          ;; let ;; TODO: Convert assignment: temp6 = temp6 / 4          lda temp6          lsr          lsr          sta temp6

          lda temp6
          lsr
          lsr
          sta temp6

          lda temp6
          lsr
          lsr
          sta temp6


                    if temp6 & $80 then let ;; TODO: Convert assignment: temp6 = 0

          lda temp6
          cmp # 32
          bcc skip_9653
          lda # 31
          sta temp6
skip_9653:




                    let ;; TODO: Convert assignment: playfieldRow = temp3 / 16


          ;; if playfieldRow >= pfrows then let
          lda playfieldRow
          cmp pfrows
          bcc skip_7030
          let_label:

          jmp let_label
skip_7030: lda pfrows
 sec
 sbc #1
 sta playfieldRow


lda pfrows

          sec

sbc 1

sta playfieldRow


                    if playfieldRow & $80 then let ;; TODO: Convert assignment: playfieldRow = 0

          lda playfieldRow
          and #$80
          beq skip_6159
          lda # 0
          sta playfieldRow
skip_6159:
          lda temp6
          cmp # 0
          bne skip_4423
          jmp PFCheckRight
skip_4423:




          lda temp6
          sec
          sbc # 1
          sta temp1

          lda # 0
          sta temp3

          ;; Cross-bank call to PF_ProcessHorizontalCollision in bank 10
          lda # >(return_point_1_L184-1)
          pha
          lda # <(return_point_1_L184-1)
          pha
          lda # >(PF_ProcessHorizontalCollision-1)
          pha
          lda # <(PF_ProcessHorizontalCollision-1)
          pha
                    ldx # 9
          jmp BS_jsr
return_point_1_L184:





PFCheckRight .proc
          ;; Returns: Far (return otherbank)

          if temp6 >= 31 then goto PFCheckUp
          lda temp6
          cmp 31

          bcc skip_4136

          jmp skip_4136

          skip_4136:



          lda temp6
          clc
          adc # 4
          sta temp1

          lda # 1
          sta temp3

          ;; Cross-bank call to PF_ProcessHorizontalCollision in bank 10
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(PF_ProcessHorizontalCollision-1)
          pha
          lda # <(PF_ProcessHorizontalCollision-1)
          pha
                    ldx # 9
          jmp BS_jsr
return_point:




.pend

PFCheckUp .proc
          ;; Returns: Far (return otherbank)

          lda playfieldRow
          cmp # 0
          bne skip_6982
          jmp PFCheckDown_Body
skip_6982:




          lda playfieldRow
          sec
          sbc # 1
          sta rowCounter

          lda rowCounter
          sta temp2

          ;; Cross-bank call to PF_CheckRowColumns in bank 10
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(PF_CheckRowColumns-1)
          pha
          lda # <(PF_CheckRowColumns-1)
          pha
                    ldx # 9
          jmp BS_jsr
return_point:


                    if temp4 then goto PFBlockUp
          lda temp4
          beq skip_8518
          jmp PFBlockUp
skip_8518:

          jmp PFCheckDown_Body



.pend

PFBlockUp .proc

          ;; Skip zeroing velocity for Radish Goblin (bounce system handles it)
          ;; Returns: Far (return otherbank)

                    if playerCharacter[currentPlayer] = CharacterRadishGoblin then goto PFBlockUpClamp

                    if playerVelocityY[currentPlayer] & $80 then let playerVelocityY[currentPlayer] = 0 : let playerVelocityYL[currentPlayer] = 0
          lda currentPlayer
          asl
          tax
          lda playerVelocityY,x
          and #$80
          beq skip_6900
          lda # 0
          sta playerVelocityY,x
          lda currentPlayer
          asl
          tax
          lda # 0
          sta playerVelocityYL,x
skip_6900:

.pend

PFBlockUpClamp .proc
          lda playfieldRow
          clc
          adc # 1
          sta rowYPosition

                    let ;; TODO: Convert assignment: rowYPosition = rowYPosition * 16


                    if playerY[currentPlayer] < rowYPosition then let playerY[currentPlayer] = rowYPosition
          lda currentPlayer
          asl
          tax
          lda playerY,x
          cmp rowYPosition
          bcs skip_254
          lda rowYPosition
          sta playerY,x
skip_254:

                    if playerY[currentPlayer] < rowYPosition then let playerSubpixelY_W[currentPlayer] = rowYPosition
          lda currentPlayer
          asl
          tax
          lda playerY,x
          cmp rowYPosition
          bcs skip_1234
          lda rowYPosition
          sta playerSubpixelY_W,x
skip_1234:

                    if playerY[currentPlayer] < rowYPosition then let playerSubpixelY_WL[currentPlayer] = 0
          lda currentPlayer
          asl
          tax
          lda playerY,x
          cmp rowYPosition
          bcs skip_4354
          lda 0
          sta playerSubpixelY_WL,x
skip_4354:

.pend

PFBlockDown .proc

          ;; Skip zeroing velocity for Radish Goblin (bounce system handles it)
          ;; Returns: Far (return otherbank)
          jsr BS_return

                    if playerVelocityY[currentPlayer] > 0 then let playerVelocityY[currentPlayer] = 0 : let playerVelocityYL[currentPlayer] = 0
          jsr BS_return

.pend

PF_CheckColumnSpan .proc


          ;; Helper: sample a column at up to three row offsets (top/mid/bottom)
          ;; Returns: Far (return otherbank)

          ;; Input: playfieldColumn (global), playfieldRow (global top row), ;; TODO: Convert assignment: temp3 = row span


          ;; Output: ;; TODO: Convert assignment: temp4 = 1 if any solid pixel encountered


          ;; TODO: dim ;; TODO: Convert assignment: PCC_rowSpan = temp3


          ;; TODO: dim ;; TODO: Convert assignment: PCC_result = temp4


          lda # 0
          sta PCC_result

          lda playfieldRow
          sta rowCounter

          lda # 0
          sta temp3

.pend

PFCS_SampleLoop .proc

                    if rowCounter & $80 then goto PFCS_Advance

          if rowCounter >= pfrows then goto PFCS_Advance
          lda rowCounter
          cmp pfrows
          bcc skip_5083
          jmp
skip_5083:


          label_unknown:

          lda playfieldColumn
          sta temp1

          lda rowCounter
          sta temp2

          ;; Cross-bank call to PlayfieldRead in bank 16
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(PlayfieldRead-1)
          pha
          lda # <(PlayfieldRead-1)
          pha
                    ldx # 15
          jmp BS_jsr
return_point:


                    if temp1 then let ;; TODO: Convert assignment: PCC_result = 1 : goto PFCS_Done          lda temp1          beq skip_351

skip_351:
          jmp skip_351

.pend

PFCS_Advance .proc

          inc temp3

          if temp3 >= 3 then goto PFCS_Done
          lda temp3
          cmp 3

          bcc skip_4503

          jmp skip_4503

          skip_4503:

          lda PCC_rowSpan
          cmp # 0
          bne skip_8939
          jmp PFCS_Done
skip_8939:


                    let ;; TODO: Convert assignment: rowCounter = rowCounter + PCC_rowSpan

          jmp PFCS_SampleLoop



PFCS_Done
          ;; Returns: Far (return otherbank)

          lda PCC_result
          sta temp4

          jsr BS_return

.pend

PF_CheckRowColumns .proc


          ;; Helper: test current row for center/side collisions
          ;; Returns: Far (return otherbank)

          ;; Input: ;; TODO: Convert assignment: temp2 = row index, temp6 = center column


          ;; Output: ;; TODO: Convert assignment: temp4 = 1 if any column collides


          dim ;; TODO: Convert assignment: PRC_rowIndex = temp2 (dim removed - variable definitions handled elsewhere)


          ;; TODO: dim ;; TODO: Convert assignment: PRC_result = temp4


          lda # 0
          sta PRC_result

          jsr BS_return

          jsr BS_return



          lda temp6
          sta temp1

          lda PRC_rowIndex
          sta temp2

          ;; Cross-bank call to PlayfieldRead in bank 16
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(PlayfieldRead-1)
          pha
          lda # <(PlayfieldRead-1)
          pha
                    ldx # 15
          jmp BS_jsr
return_point:


                    if temp1 then let ;; TODO: Convert assignment: PRC_result = 1 : goto PRC_Done          lda temp1          beq skip_6294

skip_6294:
          jmp skip_6294
          lda temp6
          cmp # 1
          bcc skip_549
skip_549:


          jmp PRC_CheckRight

.pend

PRC_CheckLeft .proc

          lda temp6
          sec
          sbc # 1
          sta temp1

          lda PRC_rowIndex
          sta temp2

          ;; Cross-bank call to PlayfieldRead in bank 16
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(PlayfieldRead-1)
          pha
          lda # <(PlayfieldRead-1)
          pha
                    ldx # 15
          jmp BS_jsr
return_point:


                    if temp1 then let ;; TODO: Convert assignment: PRC_result = 1 : goto PRC_Done          lda temp1          beq skip_6294

skip_6294:
          jmp skip_6294

.pend

PRC_CheckRight .proc

          if temp6 >= 31 then goto PRC_Done
          lda temp6
          cmp 31

          bcc skip_2626

          jmp skip_2626

          skip_2626:

          lda temp6
          clc
          adc # 1
          sta temp1

          lda PRC_rowIndex
          sta temp2

          ;; Cross-bank call to PlayfieldRead in bank 16
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(PlayfieldRead-1)
          pha
          lda # <(PlayfieldRead-1)
          pha
                    ldx # 15
          jmp BS_jsr
return_point:


                    if temp1 then let ;; TODO: Convert assignment: PRC_result = 1          lda temp1          beq skip_3174

skip_3174:
          jmp skip_3174

PRC_Done
          lda PRC_result
          sta temp4

          jsr BS_return

PF_ProcessHorizontalCollision
          ;; Returns: Far (return otherbank)


PF_ProcessHorizontalCollision


          ;; Helper: evaluate horizontal collision for given column and clamp
          ;; Returns: Far (return otherbank)

          ;; Input: ;; TODO: Convert assignment: temp1 = column index, temp3 = direction (0=left, 1=right)


          ;; TODO: dim ;; TODO: Convert assignment: PHC_column = temp1


          ;; TODO: dim ;; TODO: Convert assignment: PHC_direction = temp3


          jsr BS_return

          jsr BS_return



          lda PHC_column
          sta playfieldColumn

          lda temp5
          sta temp3

          ;; Cross-bank call to PF_CheckColumnSpan in bank 10
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(PF_CheckColumnSpan-1)
          pha
          lda # <(PF_CheckColumnSpan-1)
          pha
                    ldx # 9
          jmp BS_jsr
return_point:


          jsr BS_return



          lda currentPlayer
          sta temp1

                    if playerCharacter[temp1] = CharacterRadishGoblin then goto PHC_ClampOnly

                    if PHC_direction then goto PHC_CheckRightVelocity
          lda PHC_direction
          beq skip_3527
          jmp PHC_CheckRightVelocity
skip_3527:

                    if playerVelocityX[temp1] & $80 then let playerVelocityX[temp1] = 0 : let playerVelocityXL[temp1] = 0
          jmp PHC_ClampOnly

.pend

PHC_CheckRightVelocity .proc

                    if playerVelocityX[temp1] > 0 then let playerVelocityX[temp1] = 0 : let playerVelocityXL[temp1] = 0

PHC_ClampOnly
          lda temp6
          sta rowYPosition

                    if PHC_direction then goto PHC_ClampRight
          lda PHC_direction
          beq skip_5775
          jmp PHC_ClampRight
skip_5775:

          inc rowYPosition

                    let ;; TODO: Convert assignment: rowYPosition = rowYPosition * 4


                    let ;; TODO: Convert assignment: rowYPosition = rowYPosition + ScreenInsetX

          lda rowYPosition
          clc
          adc ScreenInsetX
          sta rowYPosition

                    if playerX[temp1] < rowYPosition then let playerX[temp1] = rowYPosition
          lda temp1
          asl
          tax
          lda playerX,x
          cmp rowYPosition
          bcs skip_7094
          lda rowYPosition
          sta playerX,x
skip_7094:

                    if playerX[temp1] < rowYPosition then let playerSubpixelX_W[temp1] = rowYPosition
          lda temp1
          asl
          tax
          lda playerX,x
          cmp rowYPosition
          bcs skip_7776
          lda rowYPosition
          sta playerSubpixelX_W,x
skip_7776:

                    if playerX[temp1] < rowYPosition then let playerSubpixelX_WL[temp1] = 0
          lda temp1
          asl
          tax
          lda playerX,x
          cmp rowYPosition
          bcs skip_945
          lda 0
          sta playerSubpixelX_WL,x
skip_945:
          jsr BS_return

.pend

PHC_ClampRight .proc

          dec rowYPosition

                    let ;; TODO: Convert assignment: rowYPosition = rowYPosition * 4


                    let ;; TODO: Convert assignment: rowYPosition = rowYPosition + ScreenInsetX

          lda rowYPosition
          clc
          adc ScreenInsetX
          sta rowYPosition

                    if playerX[temp1] > rowYPosition then let playerX[temp1] = rowYPosition
          lda temp1
          asl
          tax
          lda playerX,x
          sec
          sbc rowYPosition
          bcc skip_9821
          beq skip_9821
          lda rowYPosition
          sta playerX,x
skip_9821:

                    if playerX[temp1] > rowYPosition then let playerSubpixelX_W[temp1] = rowYPosition
          lda temp1
          asl
          tax
          lda playerX,x
          sec
          sbc rowYPosition
          bcc skip_6112
          beq skip_6112
          lda rowYPosition
          sta playerSubpixelX_W,x
skip_6112:

                    if playerX[temp1] > rowYPosition then let playerSubpixelX_WL[temp1] = 0
          lda temp1
          asl
          tax
          lda playerX,x
          sec
          sbc rowYPosition
          bcc skip_61
          beq skip_61
          lda temp1
          asl
          tax
          lda # 0
          sta playerSubpixelX_WL,x
skip_61:
          jsr BS_return

.pend

PFCheckDown_Body .proc

                    let ;; TODO: Convert assignment: rowCounter = playfieldRow + temp5

          jsr BS_return



          lda rowCounter
          clc
          adc # 1
          sta playfieldRow

          jsr BS_return



          lda playfieldRow
          sta temp2

          ;; Cross-bank call to PF_CheckRowColumns in bank 10
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(PF_CheckRowColumns-1)
          pha
          lda # <(PF_CheckRowColumns-1)
          pha
                    ldx # 9
          jmp BS_jsr
return_point:


                    if temp4 then goto PFBlockDown
          lda temp4
          beq skip_5737
          jmp PFBlockDown
skip_5737:

          jsr BS_return



.pend

