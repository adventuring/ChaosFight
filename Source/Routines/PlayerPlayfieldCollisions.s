;;; ChaosFight - Source/Routines/PlayerPlayfieldCollisions.bas

;;; Copyright © 2025 Bruce-Robert Pocock.



CheckPlayfieldCollisionAllDirections:
          ;; Returns: Far (return otherbank)

          ;; Check Playfield Collision All Directions
          ;; Returns: Far (return otherbank)

          ;; Checks for playfield pixel collisions in all four directions and blocks movement by zeroing velocity.

          ;; Uses CharacterHeights table for proper hitbox detection.

          ;;
          ;; Input: ;; TODO: #1298 Convert assignment: currentPlayer = player index (0-3)

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

          let ;; TODO: Convert assignment: temp2 = playerX[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda playerX,x
          sta temp2

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
          sta temp5

          ;; let ;; TODO: Convert assignment: temp6 = temp2 - ScreenInsetX
          lda temp2
          sec
          sbc # ScreenInsetX
          sta temp6

          ;; let ;; TODO: Convert assignment: temp6 = temp6 / 4
          lda temp6
          lsr
          lsr
          sta temp6

          if temp6 & $80 then let ;; TODO: Convert assignment: temp6 = 0

          lda temp6
          cmp # 32
          bcc ColumnInRange

          lda # 31
          sta temp6

ColumnInRange:

          let ;; TODO: Convert assignment: playfieldRow = temp3 / 16

          ;; if playfieldRow >= pfrows then let
          lda playfieldRow
          cmp pfrows
          bcc skip_7030

          lda pfrows
          sec
          sbc # 1
          sta playfieldRow

RowInRange:

          if playfieldRow & $80 then let ;; TODO: Convert assignment: playfieldRow = 0

          lda playfieldRow
          and #$80
          beq CheckLeftCollision
          lda # 0
          sta playfieldRow
CheckLeftCollision:
          lda temp6
          cmp # 0
          bne ProcessLeftCollision
          jmp PFCheckRight
ProcessLeftCollision:




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

          ;; if temp6 >= 31 then goto PFCheckUp
          lda temp6
          cmp # 31

          bcc ProcessRightCollision

          jmp PFCheckUp

ProcessRightCollision:

          lda temp6
          clc
          adc # 4
          sta temp1

          lda # 1
          sta temp3

          ;; Cross-bank call to PF_ProcessHorizontalCollision in bank 10
          lda # >(return_point2-1)
          pha
          lda # <(return_point2-1)
          pha
          lda # >(PF_ProcessHorizontalCollision-1)
          pha
          lda # <(PF_ProcessHorizontalCollision-1)
          pha
          ldx # 9
          jmp BS_jsr

return_point2:

.pend

PFCheckUp .proc
          ;; Returns: Far (return otherbank)

          lda playfieldRow
          cmp # 0
          bne CheckUpCollision

          jmp PFCheckDown_Body

CheckUpCollision:

          lda playfieldRow
          sec
          sbc # 1
          sta rowCounter

          lda rowCounter
          sta temp2

          ;; Cross-bank call to PF_CheckRowColumns in bank 10
          lda # >(return_point3-1)
          pha
          lda # <(return_point3-1)
          pha
          lda # >(PF_CheckRowColumns-1)
          pha
          lda # <(PF_CheckRowColumns-1)
          pha
          ldx # 9
          jmp BS_jsr

return_point3:

          ;; if temp4 then goto PFBlockUp
          lda temp4
          beq PFCheckDown_Body

          jmp PFBlockUp

PFCheckDown_Body:

          jmp PFCheckDown_Body

.pend

PFBlockUp .proc

          ;; Skip zeroing velocity for Radish Goblin (bounce system handles it)
          ;; Returns: Far (return otherbank)

          ;; if playerCharacter[currentPlayer] = CharacterRadishGoblin then goto PFBlockUpClamp

                    if playerVelocityY[currentPlayer] & $80 then let playerVelocityY[currentPlayer] = 0 : let playerVelocityYL[currentPlayer] = 0
          lda currentPlayer
          asl
          tax
          lda playerVelocityY,x
          and #$80
          beq PFBlockUpDone
          lda # 0
          sta playerVelocityY,x
          lda currentPlayer
          asl
          tax
          lda # 0
          sta playerVelocityYL,x
PFBlockUpDone:

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
          bcs ClampSubpixelY
          lda rowYPosition
          sta playerY,x
ClampSubpixelY:

                    if playerY[currentPlayer] < rowYPosition then let playerSubpixelY_W[currentPlayer] = rowYPosition
          lda currentPlayer
          asl
          tax
          lda playerY,x
          cmp rowYPosition
          bcs ClampSubpixelYL
          lda rowYPosition
          sta playerSubpixelY_W,x
ClampSubpixelYL:

                    if playerY[currentPlayer] < rowYPosition then let playerSubpixelY_WL[currentPlayer] = 0
          lda currentPlayer
          asl
          tax
          lda playerY,x
          cmp rowYPosition
          bcs PFBlockUpClampDone
          lda 0
          sta playerSubpixelY_WL,x
PFBlockUpClampDone:

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


          ;; TODO: #1298 dim ;; TODO: #1298 Convert assignment: PCC_rowSpan = temp3


          ;; TODO: #1298 dim ;; TODO: #1298 Convert assignment: PCC_result = temp4


          lda # 0
          sta PCC_result

          lda playfieldRow
          sta rowCounter

          lda # 0
          sta temp3

.pend

PFCS_SampleLoop .proc

          ;; if rowCounter & $80 then goto PFCS_Advance

          ;; if rowCounter >= pfrows then goto PFCS_Advance
          lda rowCounter
          cmp pfrows
          bcc SamplePlayfieldPixel
          jmp
SamplePlayfieldPixel:


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


                    if temp1 then let ;; TODO: Convert assignment: PCC_result = 1 : goto PFCS_Done          lda temp1          beq PFCS_AdvanceLabel

PFCS_AdvanceLabel:
          jmp PFCS_AdvanceLabel

.pend

PFCS_Advance .proc

          inc temp3

          ;; if temp3 >= 3 then goto PFCS_Done
          lda temp3
          cmp 3

          bcc AdvanceRowCounter

          jmp AdvanceRowCounter

          AdvanceRowCounter:

          lda PCC_rowSpan
          cmp # 0
          bne IncrementRowCounter
          jmp PFCS_Done
IncrementRowCounter:


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


          ;; TODO: #1298 dim ;; TODO: #1298 Convert assignment: PRC_result = temp4


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


                    if temp1 then let ;; TODO: Convert assignment: PRC_result = 1 : goto PRC_Done          lda temp1          beq CheckRightColumnCenter

CheckRightColumnCenter:
          jmp CheckRightColumnCenter
          lda temp6
          cmp # 1
          bcc PRC_CheckRight
PRC_CheckRight:


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


                    if temp1 then let ;; TODO: Convert assignment: PRC_result = 1 : goto PRC_Done          lda temp1          beq PRC_DoneLabel

PRC_DoneLabel:
          jmp PRC_DoneLabel

.pend

PRC_CheckRight .proc

          ;; if temp6 >= 31 then goto PRC_Done
          lda temp6
          cmp 31

          bcc CheckRightColumnCollision

          jmp CheckRightColumnCollision

          CheckRightColumnCollision:

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


                    if temp1 then let ;; TODO: Convert assignment: PRC_result = 1          lda temp1          beq PRC_DoneLabel2

PRC_DoneLabel2:
          jmp PRC_DoneLabel2

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


          ;; TODO: #1298 dim ;; TODO: #1298 Convert assignment: PHC_column = temp1


          ;; TODO: #1298 dim ;; TODO: #1298 Convert assignment: PHC_direction = temp3


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

          ;; if playerCharacter[temp1] = CharacterRadishGoblin then goto PHC_ClampOnly

          ;; if PHC_direction then goto PHC_CheckRightVelocity
          lda PHC_direction
          beq CheckLeftVelocity
          jmp PHC_CheckRightVelocity
CheckLeftVelocity:

                    if playerVelocityX[temp1] & $80 then let playerVelocityX[temp1] = 0 : let playerVelocityXL[temp1] = 0
          jmp PHC_ClampOnly

.pend

PHC_CheckRightVelocity .proc

                    if playerVelocityX[temp1] > 0 then let playerVelocityX[temp1] = 0 : let playerVelocityXL[temp1] = 0

PHC_ClampOnly
          lda temp6
          sta rowYPosition

          ;; if PHC_direction then goto PHC_ClampRight
          lda PHC_direction
          beq ClampLeftPosition
          jmp PHC_ClampRight
ClampLeftPosition:

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
          bcs ClampSubpixelXLeft
          lda rowYPosition
          sta playerX,x
ClampSubpixelXLeft:

                    if playerX[temp1] < rowYPosition then let playerSubpixelX_W[temp1] = rowYPosition
          lda temp1
          asl
          tax
          lda playerX,x
          cmp rowYPosition
          bcs ClampSubpixelXLLeft
          lda rowYPosition
          sta playerSubpixelX_W,x
ClampSubpixelXLLeft:

                    if playerX[temp1] < rowYPosition then let playerSubpixelX_WL[temp1] = 0
          lda temp1
          asl
          tax
          lda playerX,x
          cmp rowYPosition
          bcs PHC_ClampOnlyDone
          lda 0
          sta playerSubpixelX_WL,x
PHC_ClampOnlyDone:
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
          bcc ClampSubpixelXRight
          beq ClampSubpixelXRight
          lda rowYPosition
          sta playerX,x
ClampSubpixelXRight:

                    if playerX[temp1] > rowYPosition then let playerSubpixelX_W[temp1] = rowYPosition
          lda temp1
          asl
          tax
          lda playerX,x
          sec
          sbc rowYPosition
          bcc ClampSubpixelXLRight
          beq ClampSubpixelXLRight
          lda rowYPosition
          sta playerSubpixelX_W,x
ClampSubpixelXLRight:

                    if playerX[temp1] > rowYPosition then let playerSubpixelX_WL[temp1] = 0
          lda temp1
          asl
          tax
          lda playerX,x
          sec
          sbc rowYPosition
          bcc PHC_ClampRightDone
          beq PHC_ClampRightDone
          lda temp1
          asl
          tax
          lda # 0
          sta playerSubpixelX_WL,x
PHC_ClampRightDone:
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


          ;; if temp4 then goto PFBlockDown
          lda temp4
          beq PFCheckDownDone
          jmp PFBlockDown
PFCheckDownDone:

          jsr BS_return



.pend

