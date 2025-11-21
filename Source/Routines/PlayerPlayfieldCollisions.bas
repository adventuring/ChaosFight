          rem ChaosFight - Source/Routines/PlayerPlayfieldCollisions.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

CheckPlayfieldCollisionAllDirections
          asm
CheckPlayfieldCollisionAllDirections
end
          rem Check Playfield Collision All Directions
          rem Checks for playfield pixel collisions in all four directions and blocks movement by zeroing velocity.
          rem Uses CharacterHeights table for proper hitbox detection.
          rem
          rem Input: currentPlayer = player index (0-3)
          rem        playerX[], playerY[], playerCharacter[]
          rem        playerVelocityX[], playerVelocityY[], playerVelocityXL[], playerVelocityYL[]
          rem        playerSubpixelX[], playerSubpixelY[], playerSubpixelXL[], playerSubpixelYL[]
          rem        CharacterHeights[], ScreenInsetX, pfrowheight, pfrows
          rem
          rem Output: Player velocities zeroed when collisions detected
          rem
          rem Mutates: temp2-temp6, playfieldRow, playfieldColumn, rowCounter,
          rem           playerVelocityX[], playerVelocityY[],
          rem           playerVelocityXL[], playerVelocityYL[],
          rem           playerSubpixelX[], playerSubpixelY[],
          rem           playerSubpixelXL[], playerSubpixelYL[]
          rem
          rem Called Routines: PlayfieldRead (bank16)
          rem
          rem Constraints: Checks collisions at head, middle, and feet positions.
          let temp2 = playerX[currentPlayer]
          let temp3 = playerY[currentPlayer]
          let temp4 = playerCharacter[currentPlayer]
          let temp5 = CharacterHeights[temp4]

          let temp6 = temp2
          let temp6 = temp6 - ScreenInsetX
          asm
            lsr temp6
            lsr temp6
end
          if temp6 & $80 then temp6 = 0
          if temp6 > 31 then temp6 = 31

          let playfieldRow = temp3 / 16
          if playfieldRow >= pfrows then let playfieldRow = pfrows - 1
          if playfieldRow & $80 then let playfieldRow = 0

          if temp6 = 0 then goto PFCheckRight

          let playfieldColumn_W = temp6 - 1
          if playfieldColumn_R & $80 then goto PFCheckRight

          let temp4 = 0
          let temp1 = playfieldColumn_R
          let temp2 = playfieldRow_R
          gosub PlayfieldRead bank16
          if temp1 then let temp4 = 1
          if temp4 = 1 then goto PFBlockLeft
          asm
            lda temp5
            lsr
            lsr
            lsr
            lsr
            sta temp2
end
          let rowCounter_W = playfieldRow_R + temp2
          if rowCounter_R >= pfrows then goto PFCheckRight
          let temp1 = playfieldColumn_R
          let temp2 = rowCounter_R
          gosub PlayfieldRead bank16
          if temp1 then let temp4 = 1
          if temp4 = 1 then goto PFBlockLeft
          let temp2 = temp5 / 16
          let rowCounter_W = playfieldRow_R + temp2
          if rowCounter_R >= pfrows then goto PFCheckRight
          let temp1 = playfieldColumn_R
          let temp2 = rowCounter_R
          gosub PlayfieldRead bank16
          if temp1 then let temp4 = 1
          if temp4 = 1 then goto PFBlockLeft

          goto PFCheckRight

PFBlockLeft
          if playerVelocityX[currentPlayer] & $80 then let playerVelocityX[currentPlayer] = 0 : let playerVelocityXL[currentPlayer] = 0
          let rowYPosition_W = temp6 + 1
          asm
            lda rowYPosition_R
            asl
            asl
            clc
            adc #ScreenInsetX
            sta rowYPosition_W
end
          if playerX[currentPlayer] < rowYPosition_R then let playerX[currentPlayer] = rowYPosition_R
          if playerX[currentPlayer] < rowYPosition_R then let playerSubpixelX_W[currentPlayer] = rowYPosition_R
          if playerX[currentPlayer] < rowYPosition_R then let playerSubpixelX_WL[currentPlayer] = 0

PFCheckRight
          if temp6 >= 31 then goto PFCheckUp

          let playfieldColumn_W = temp6 + 4
          if playfieldColumn_R > 31 then goto PFCheckUp

          let temp4 = 0
          let temp1 = playfieldColumn_R
          let temp2 = playfieldRow
          gosub PlayfieldRead bank16
          if temp1 then let temp4 = 1
          if temp4 = 1 then goto PFBlockRight
          asm
            lda temp5
            lsr a
            lsr a
            lsr a
            lsr a
            sta temp2
end
          let rowCounter_W = playfieldRow + temp2
          if rowCounter_R >= pfrows then goto PFCheckUp
          let temp1 = playfieldColumn_R
          let temp2 = rowCounter_R
          gosub PlayfieldRead bank16
          if temp1 then let temp4 = 1
          if temp4 = 1 then goto PFBlockRight
          let temp2 = temp5 / 16
          let rowCounter_W = playfieldRow + temp2
          if rowCounter_R >= pfrows then goto PFCheckUp
          let temp1 = playfieldColumn_R
          let temp2 = rowCounter_R
          gosub PlayfieldRead bank16
          if temp1 then let temp4 = 1
          if temp4 = 1 then goto PFBlockRight

          goto PFCheckUp

PFBlockRight
          if playerVelocityX[currentPlayer] > 0 then let playerVelocityX[currentPlayer] = 0 : let playerVelocityXL[currentPlayer] = 0
          let rowYPosition_W = temp6 - 1
          asm
            lda rowYPosition_R
            asl a
            asl a
            clc
            adc #ScreenInsetX
            sta rowYPosition_W
end
          if playerX[currentPlayer] > rowYPosition_R then let playerX[currentPlayer] = rowYPosition_R
          if playerX[currentPlayer] > rowYPosition_R then let playerSubpixelX_W[currentPlayer] = rowYPosition_R
          if playerX[currentPlayer] > rowYPosition_R then let playerSubpixelX_WL[currentPlayer] = 0

PFCheckUp
          if playfieldRow = 0 then goto PFCheckDown_Body

          let rowCounter_W = playfieldRow - 1
          if rowCounter_R & $80 then goto PFCheckDown_Body

          let temp4 = 0
          let temp1 = temp6
          let temp2 = rowCounter_R
          gosub PlayfieldRead bank16
          if temp1 then let temp4 = 1
          if temp4 = 1 then goto PFBlockUp
          if temp6 = 0 then goto PFCheckUp_CheckRight
          let playfieldColumn_W = temp6 - 1
          let temp1 = playfieldColumn_R
          let temp2 = rowCounter_R
          gosub PlayfieldRead bank16
          if temp1 then let temp4 = 1
          if temp4 = 1 then goto PFBlockUp
PFCheckUp_CheckRight
          if temp6 >= 31 then goto PFCheckDown_Body
          let playfieldColumn_W = temp6 + 1
          let temp1 = playfieldColumn_R
          let temp2 = rowCounter_R
          gosub PlayfieldRead bank16
          if temp1 then let temp4 = 1
          if temp4 = 1 then goto PFBlockUp

          goto PFCheckDown_Body

PFBlockUp
          if playerVelocityY[currentPlayer] & $80 then let playerVelocityY[currentPlayer] = 0 : let playerVelocityYL[currentPlayer] = 0
          let rowYPosition_W = playfieldRow + 1
          asm
            lda rowYPosition_R
            asl a
            asl a
            asl a
            asl a
            sta rowYPosition_W
end
          if playerY[currentPlayer] < rowYPosition_R then let playerY[currentPlayer] = rowYPosition_R
          if playerY[currentPlayer] < rowYPosition_R then let playerSubpixelY_W[currentPlayer] = rowYPosition_R
          if playerY[currentPlayer] < rowYPosition_R then let playerSubpixelY_WL[currentPlayer] = 0
PFBlockDown
          if playerVelocityY[currentPlayer] > 0 then let playerVelocityY[currentPlayer] = 0 : let playerVelocityYL[currentPlayer] = 0
          return

PFCheckDown_Body
          let temp2 = temp5 / 16
          let rowCounter_W = playfieldRow + temp2
          if rowCounter_R >= pfrows then return

          let playfieldRow = rowCounter_R + 1
          if playfieldRow >= pfrows then return

          let temp4 = 0
          let temp1 = temp6
          let temp2 = playfieldRow
          gosub PlayfieldRead bank16
          if temp1 then let temp4 = 1
          if temp4 = 1 then goto PFBlockDown
          if temp6 = 0 then goto PFCheckDown_CheckRight
          let playfieldColumn_W = temp6 - 1
          let temp1 = playfieldColumn_R
          let temp2 = playfieldRow
          gosub PlayfieldRead bank16
          if temp1 then let temp4 = 1
          if temp4 = 1 then goto PFBlockDown
PFCheckDown_CheckRight
          if temp6 >= 31 then return
          let playfieldColumn_W = temp6 + 1
          let temp1 = playfieldColumn_R
          let temp2 = playfieldRow
          gosub PlayfieldRead bank16
          if temp1 then let temp4 = 1
          if temp4 = 1 then goto PFBlockDown

          return

CheckPlayfieldCollisionUpDone
          return


