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

          ;; temp2 = playerX[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda playerX,x
          sta temp2

          ;; temp3 = playerY[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda playerY,x
          sta temp3

          ;; temp4 = playerCharacter[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda playerCharacter,x
          sta temp4

          ;; temp5 = CharacterHeights[temp4]
          lda temp4
          asl
          tax
          lda CharacterHeights,x
          sta temp5

          ;; temp6 = temp2 - ScreenInsetX
          lda temp2
          sec
          sbc # ScreenInsetX
          sta temp6

          ;; temp6 = temp6 / 4
          lda temp6
          lsr
          lsr
          sta temp6

          ;; if temp6 >= 32 then temp6 = 31
          lda temp6
          cmp # 32
          bcc PFCD_ColumnInRange

          lda # 31
          sta temp6

PFCD_ColumnInRange:

          ;; playfieldRow = temp3 / 16
          lda temp3
          lsr
          lsr
          lsr
          lsr
          sta playfieldRow

          ;; if playfieldRow >= pfrows then playfieldRow = pfrows - 1
          lda playfieldRow
          cmp pfrows
          bcc RowInRange

          lda pfrows
          sec
          sbc # 1
          sta playfieldRow

RowInRange:

          ;; if playfieldRow & $80 then playfieldRow = 0
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
          lda # >(PFCheckRightReturn-1)
          pha
          lda # <(PFCheckRightReturn-1)
          pha
          lda # >(PF_ProcessHorizontalCollision-1)
          pha
          lda # <(PF_ProcessHorizontalCollision-1)
          pha
          ldx # 9
          jmp BS_jsr

PFCheckRightReturn:

PFCheckRight .proc
          ;; Returns: Far (return otherbank)

          ;; if temp6 >= 31 then jmp PFCheckUp
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
          lda # >(PFCheckLeftReturn-1)
          pha
          lda # <(PFCheckLeftReturn-1)
          pha
          lda # >(PF_ProcessHorizontalCollision-1)
          pha
          lda # <(PF_ProcessHorizontalCollision-1)
          pha
          ldx # 9
          jmp BS_jsr

PFCheckLeftReturn:

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
          lda # >(PFCheckRowColumnsReturn-1)
          pha
          lda # <(PFCheckRowColumnsReturn-1)
          pha
          lda # >(PF_CheckRowColumns-1)
          pha
          lda # <(PF_CheckRowColumns-1)
          pha
          ldx # 9
          jmp BS_jsr

PFCheckRowColumnsReturn:

          ;; if temp4 then jmp PFBlockUp
          lda temp4
          beq PFCheckDown_Body

          jmp PFBlockUp

PFCheckDown_Body:

          jmp PFCheckDown_Body

.pend

PFBlockUp .proc

          ;; Skip zeroing velocity for Radish Goblin (bounce system handles it)
          ;; Returns: Far (return otherbank)

          ;; if playerCharacter[currentPlayer] = CharacterRadishGoblin then jmp PFBlockUpClamp
          lda currentPlayer
          asl
          tax
          lda playerCharacter,x
          cmp # CharacterRadishGoblin
          beq PFBlockUpClamp

          ;; if playerVelocityY[currentPlayer] & $80 then playerVelocityY[currentPlayer] = 0 : playerVelocityYL[currentPlayer] = 0
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

          ;; rowYPosition = rowYPosition * 16
          lda rowYPosition
          asl
          asl
          asl
          asl
          sta rowYPosition

          ;; if playerY[currentPlayer] < rowYPosition then playerY[currentPlayer] = rowYPosition
          lda currentPlayer
          asl
          tax
          lda playerY,x
          cmp rowYPosition
          bcs ClampSubpixelY
          lda rowYPosition
          sta playerY,x
ClampSubpixelY:

          ;; if playerY[currentPlayer] < rowYPosition then playerSubpixelY_W[currentPlayer] = rowYPosition
          lda currentPlayer
          asl
          tax
          lda playerY,x
          cmp rowYPosition
          bcs ClampSubpixelYL
          lda rowYPosition
          sta playerSubpixelY_W,x
ClampSubpixelYL:

          ;; if playerY[currentPlayer] < rowYPosition then playerSubpixelY_WL[currentPlayer] = 0
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
          ;; if playerCharacter[currentPlayer] = CharacterRadishGoblin then skip velocity zeroing
          lda currentPlayer
          asl
          tax
          lda playerCharacter,x
          cmp # CharacterRadishGoblin
          beq PFBlockDownDone

          ;; if playerVelocityY[currentPlayer] > 0 then playerVelocityY[currentPlayer] = 0 : playerVelocityYL[currentPlayer] = 0
          lda currentPlayer
          asl
          tax
          lda playerVelocityY,x
          bpl PFBlockDownDone
          lda # 0
          sta playerVelocityY,x
          lda currentPlayer
          asl
          tax
          lda # 0
          sta playerVelocityYL,x
PFBlockDownDone:
          jmp BS_return

.pend

PF_CheckColumnSpan .proc


          ;; Helper: sample a column at up to three row offsets (top/mid/bottom)
          ;; Returns: Far (return otherbank)

          ;; Input: playfieldColumn (global), playfieldRow (global top row), ;; TODO: #1298 Convert assignment: temp3 = row span


          ;; Output: ;; TODO: #1298 Convert assignment: temp4 = 1 if any solid pixel encountered


          ;; TODO: #1298 dim ;; TODO: #1298 Convert assignment: PCC_rowSpan = temp3


          ;; PCC_result = 0 (initialize, use temp5 to store it)
          lda # 0
          sta temp5  ;;; Use temp5 to store PCC_result

          lda playfieldRow
          sta rowCounter

          lda # 0
          sta temp3

.pend

PFCS_SampleLoop .proc

          ;; if rowCounter & $80 then jmp PFCS_Advance

          ;; if rowCounter >= pfrows then jmp PFCS_Advance
          lda rowCounter
          cmp pfrows
          bcc PFCS_ReadPlayfieldPixel
          jmp PFCS_Advance
PFCS_ReadPlayfieldPixel:

          lda playfieldColumn
          sta temp1

          lda rowCounter
          sta temp2

          ;; Cross-bank call to PlayfieldRead in bank 16
          lda # >(AfterPlayfieldReadColumnSpan-1)
          pha
          lda # <(AfterPlayfieldReadColumnSpan-1)
          pha
          lda # >(PlayfieldRead-1)
          pha
          lda # <(PlayfieldRead-1)
          pha
                    ldx # 15
          jmp BS_jsr
AfterPlayfieldReadColumnSpan:


          ;; if temp1 then PCC_result = 1 : jmp PFCS_Done
          lda temp1
          beq PFCS_AdvanceLabel
          lda # 1
          sta temp5  ;;; PCC_result = 1
          jmp PFCS_Done

PFCS_AdvanceLabel:
          jmp PFCS_AdvanceLabel

.pend

PFCS_Advance .proc

          inc temp3

          ;; if temp3 >= 3 then jmp PFCS_Done
          lda temp3
          cmp 3

          bcc AdvanceRowCounter

          jmp AdvanceRowCounter

          AdvanceRowCounter:

          lda temp3
          cmp # 0
          bne IncrementRowCounter
          jmp PFCS_Done
IncrementRowCounter:


                    ;; TODO: #1298 Convert assignment: rowCounter = rowCounter + PCC_rowSpan

          jmp PFCS_SampleLoop

.pend

PFCS_Done:
          ;; Returns: Far (return otherbank)

          lda temp5  ;;; PCC_result
          sta temp4

          jmp BS_return

PF_CheckRowColumns .proc


          ;; Helper: test current row for center/side collisions
          ;; Returns: Far (return otherbank)

          ;; Input: ;; TODO: #1298 Convert assignment: temp2 = row index, temp6 = center column


          ;; Output: ;; TODO: #1298 Convert assignment: temp4 = 1 if any column collides


          ;; PRC_rowIndex = temp2
          lda temp2
          sta temp3  ;;; Use temp3 to store PRC_rowIndex

          ;; PRC_result = 0 (initialize)
          lda # 0
          sta temp4  ;;; Use temp4 to store PRC_result

          lda temp6
          sta temp1

          lda temp3  ;;; PRC_rowIndex
          sta temp2

          ;; Cross-bank call to PlayfieldRead in bank 16
          lda # >(AfterPlayfieldReadCenter-1)
          pha
          lda # <(AfterPlayfieldReadCenter-1)
          pha
          lda # >(PlayfieldRead-1)
          pha
          lda # <(PlayfieldRead-1)
          pha
                    ldx # 15
          jmp BS_jsr
AfterPlayfieldReadCenter:


          ;; if temp1 then PRC_result = 1 : jmp PRC_Done
          lda temp1
          beq CheckRightColumnCenter
          lda # 1
          sta temp4  ;;; PRC_result = 1
          jmp PRC_Done

CheckRightColumnCenter:
          lda temp6
          cmp # 1
          bcc PRC_CheckRight
          jmp PRC_Done

.pend

PRC_CheckRight .proc
          ;; Check right column for collision
          lda temp6
          clc
          adc # 1
          sta temp1
          lda temp3  ;;; PRC_rowIndex
          sta temp2
          ;; Cross-bank call to PlayfieldRead in bank 16
          lda # >(PRC_CheckRight_return-1)
          pha
          lda # <(PRC_CheckRight_return-1)
          pha
          lda # >(PlayfieldRead-1)
          pha
          lda # <(PlayfieldRead-1)
          pha
          ldx # 15
          jmp BS_jsr
PRC_CheckRight_return:
          ;; if temp1 then PRC_result = 1
          lda temp1
          beq PRC_CheckRightDone
          lda # 1
          sta temp4  ;;; PRC_result = 1
PRC_CheckRightDone:
          jmp PRC_Done

.pend

PRC_CheckLeft .proc
          lda temp6
          sec
          sbc # 1
          sta temp1

          lda temp3  ;;; PRC_rowIndex
          sta temp2

          ;; Cross-bank call to PlayfieldRead in bank 16
          lda # >(PRC_CheckLeft_return-1)
          pha
          lda # <(PRC_CheckLeft_return-1)
          pha
          lda # >(PlayfieldRead-1)
          pha
          lda # <(PlayfieldRead-1)
          pha
          ldx # 15
          jmp BS_jsr
PRC_CheckLeft_return:

          ;; if temp1 then PRC_result = 1 : jmp PRC_Done
          lda temp1
          beq PRC_CheckLeftDone
          lda # 1
          sta temp4  ;;; PRC_result = 1
PRC_CheckLeftDone:
          jmp PRC_Done

.pend

PRC_Done .proc
          lda temp4  ;;; PRC_result
          sta temp4
          jmp BS_return

.pend

PF_ProcessHorizontalCollision .proc
          ;; Returns: Far (return otherbank)


          ;; Helper: evaluate horizontal collision for given column and clamp
          ;; Returns: Far (return otherbank)

          ;; Input: temp1 = column index, temp3 = direction (0=left, 1=right)
          ;; PHC_column = temp1 (use temp2 to store it)
          ;; PHC_direction = temp3 (use temp4 to store it)
          lda temp1
          sta temp2  ;;; PHC_column
          lda temp3
          sta temp4  ;;; PHC_direction

          lda temp2  ;;; PHC_column
          sta playfieldColumn

          lda temp5
          sta temp3

          ;; Cross-bank call to PF_CheckColumnSpan in bank 10
          lda # >(AfterCheckColumnSpan-1)
          pha
          lda # <(AfterCheckColumnSpan-1)
          pha
          lda # >(PF_CheckColumnSpan-1)
          pha
          lda # <(PF_CheckColumnSpan-1)
          pha
                    ldx # 9
          jmp BS_jsr
AfterCheckColumnSpan:


          jmp BS_return



          lda currentPlayer
          sta temp1

          ;; if playerCharacter[temp1] = CharacterRadishGoblin then jmp PHC_ClampOnly
          lda temp1
          asl
          tax
          lda playerCharacter,x
          cmp # CharacterRadishGoblin
          beq PHC_ClampOnly

          ;; if PHC_direction then jmp PHC_CheckRightVelocity
          lda temp4  ;;; PHC_direction
          beq CheckLeftVelocity
          jmp PHC_CheckRightVelocity
CheckLeftVelocity:

          ;; if playerVelocityX[temp1] & $80 then playerVelocityX[temp1] = 0 : playerVelocityXL[temp1] = 0
          lda temp1
          asl
          tax
          lda playerVelocityX,x
          and #$80
          beq PHC_CheckRightVelocity
          lda # 0
          sta playerVelocityX,x
          lda temp1
          asl
          tax
          lda # 0
          sta playerVelocityXL,x

PHC_ClampOnly:
          lda temp6
          sta rowYPosition

          ;; if PHC_direction then jmp PHC_ClampRight
          lda temp4  ;;; PHC_direction
          beq ClampLeftPositionFirst
          jmp PHC_ClampRight
ClampLeftPositionFirst:

.pend

PHC_CheckRightVelocity .proc

          ;; if playerVelocityX[temp1] > 0 then playerVelocityX[temp1] = 0 : playerVelocityXL[temp1] = 0
          lda temp1
          asl
          tax
          lda playerVelocityX,x
          bpl PHC_ClampOnly
          lda # 0
          sta playerVelocityX,x
          lda temp1
          asl
          tax
          lda # 0
          sta playerVelocityXL,x

PHC_ClampOnly:
          lda temp6
          sta rowYPosition

          ;; if PHC_direction then jmp PHC_ClampRight
          lda temp4  ;;; PHC_direction
          beq ClampLeftPositionSecond
          jmp PHC_ClampRight
ClampLeftPositionSecond:

          inc rowYPosition

          ;; rowYPosition = rowYPosition * 4
          lda rowYPosition
          asl
          asl
          sta rowYPosition

          ;; rowYPosition = rowYPosition + ScreenInsetX
          lda rowYPosition
          clc
          adc # ScreenInsetX
          sta rowYPosition

          ;; if playerX[temp1] < rowYPosition then playerX[temp1] = rowYPosition
          lda temp1
          asl
          tax
          lda playerX,x
          cmp rowYPosition
          bcs ClampSubpixelXLeft
          lda rowYPosition
          sta playerX,x
ClampSubpixelXLeft:

          ;; if playerX[temp1] < rowYPosition then playerSubpixelX_W[temp1] = rowYPosition
          lda temp1
          asl
          tax
          lda playerX,x
          cmp rowYPosition
          bcs ClampSubpixelXLLeft
          lda rowYPosition
          sta playerSubpixelX_W,x
ClampSubpixelXLLeft:

          ;; if playerX[temp1] < rowYPosition then playerSubpixelX_WL[temp1] = 0
          lda temp1
          asl
          tax
          lda playerX,x
          cmp rowYPosition
          bcs PHC_ClampOnlyDone
          lda 0
          sta playerSubpixelX_WL,x
PHC_ClampOnlyDone:
          jmp BS_return

.pend

PHC_ClampRight .proc

          dec rowYPosition

          ;; rowYPosition = rowYPosition * 4
          lda rowYPosition
          asl
          asl
          sta rowYPosition

          ;; rowYPosition = rowYPosition + ScreenInsetX
          lda rowYPosition
          clc
          adc # ScreenInsetX
          sta rowYPosition

          ;; if playerX[temp1] > rowYPosition then playerX[temp1] = rowYPosition
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

          ;; if playerX[temp1] > rowYPosition then playerSubpixelX_W[temp1] = rowYPosition
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

          ;; if playerX[temp1] > rowYPosition then playerSubpixelX_WL[temp1] = 0
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
          jmp BS_return

.pend

PFCheckDown_Body .proc

                    ;; TODO: #1298 Convert assignment: rowCounter = playfieldRow + temp5

          jmp BS_return



          lda rowCounter
          clc
          adc # 1
          sta playfieldRow

          jmp BS_return



          lda playfieldRow
          sta temp2

          ;; Cross-bank call to PF_CheckRowColumns in bank 10
          lda # >(AfterCheckRowColumns-1)
          pha
          lda # <(AfterCheckRowColumns-1)
          pha
          lda # >(PF_CheckRowColumns-1)
          pha
          lda # <(PF_CheckRowColumns-1)
          pha
                    ldx # 9
          jmp BS_jsr
AfterCheckRowColumns:


          ;; if temp4 then jmp PFBlockDown
          lda temp4
          beq PFCheckDownDone
          jmp PFBlockDown
PFCheckDownDone:

          jmp BS_return



.pend

