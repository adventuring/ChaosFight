          rem ChaosFight - Source/Routines/PlayerRendering.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem PLAYER SPRITE RENDERING
          rem =================================================================
          rem Handles sprite positioning, colors, and graphics for all players.

          rem SPRITE ASSIGNMENTS (MULTISPRITE KERNEL):
          rem   Participant 1 (array [0]): P0 sprite (player0x/player0y, COLUP0)
          rem   Participant 2 (array [1]): P1 sprite (player1x/player1y, _COLUP1 - virtual sprite)
          rem   Participant 3 (array [2]): P2 sprite (player2x/player2y, COLUP2)
          rem   Participant 4 (array [3]): P3 sprite (player3x/player3y, COLUP3)

          rem MISSILE SPRITES:
          rem   2-player mode: missile0 = Participant 1, missile1 = Participant 2 (no multiplexing)
          rem   4-player mode: missile0 and missile1 multiplexed between all 4 participants (even/odd frames)

          rem AVAILABLE VARIABLES:
          rem   playerX[0-3], playerY[0-3] - Positions
          rem   playerState[0-3] - State flags
          rem   playerRecoveryFrames[0-3] - Hitstun frames
          rem   missileActive (bit flags) - Projectile states (bit 0=P0, bit 1=P1, bit 2=P2, bit 3=P3)
          rem   missileX[0-3], missileY[0-3] - Projectile positions
          rem   QuadtariDetected, selectedChar3, selectedChar4
          rem =================================================================

          rem =================================================================
          rem SET SPRITE POSITIONS
          rem =================================================================
          rem Updates hardware sprite position registers for all active entities.
SetSpritePositions
          rem Set player sprite positions
          player0x = playerX[0]
          player0y = playerY[0]
          player1x = playerX[1]
          player1y = playerY[1]

          rem Set positions for participants 3 & 4 in 4-player mode (multisprite kernel)
          rem Participant 3 (array [2]): P2 sprite (player2x/player2y, COLUP2)
          rem Participant 4 (array [3]): P3 sprite (player3x/player3y, COLUP3)
          rem Missiles are available for projectiles since participants use proper sprites
          
          rem Set Participant 3 position (array [2] → P2 sprite)
          if !(controllerStatus & SetQuadtariDetected) then goto SkipPlayer3Position
          if selectedChar3 = 255 then goto SkipPlayer3Position
          if ! playerHealth[2] then goto SkipPlayer3Position
          let player2x = playerX[2]
          let player2y = playerY[2]
SkipPlayer3Position
          
          rem Set Participant 4 position (array [3] → P3 sprite)
          if !(controllerStatus & SetQuadtariDetected) then goto SkipPlayer4Position
          if selectedChar4 = 255 then goto SkipPlayer4Position
          if ! playerHealth[3] then goto SkipPlayer4Position
          let player3x = playerX[3]
          let player3y = playerY[3]
SkipPlayer4Position
          

          rem Set missile positions for projectiles
          rem Hardware missiles: missile0 and missile1 (only 2 physical missiles available on TIA)
          rem In 2-player mode: missile0 = Participant 1, missile1 = Participant 2 (no multiplexing needed)
          rem In 4-player mode: Use frame multiplexing to support 4 logical missiles with 2 hardware missiles:
          rem   Even frames: missile0 = Participant 1 (array [0]), missile1 = Participant 2 (array [1])
          rem   Odd frames:  missile0 = Participant 3 (array [2]), missile1 = Participant 4 (array [3])
          rem Use missileActive bit flags: bit 0 = Participant 1, bit 1 = Participant 2, bit 2 = Participant 3, bit 3 = Participant 4
          
          rem Check if participants 3 or 4 are active (selected and not eliminated)
          rem Use this flag instead of QuadtariDetected for missile multiplexing
          rem because we only need to multiplex when participants 3 or 4 are actually in the game
          if !(controllerStatus & SetPlayers34Active) then goto RenderMissiles2Player
          
          rem 4-player mode: Use frame multiplexing
          dim SSP_frameParity = temp6
          dim SSP_missileActive = temp4
          let SSP_frameParity = frame & 1
          rem 0 = even frame (Participants 1-2), 1 = odd frame (Participants 3-4)
          
          if SSP_frameParity = 0 then goto RenderMissilesEvenFrame
          
                    rem Odd frame: Render Participants 3-4 missiles
          rem Participant 3 missile (array [2], bit 2) → missile0
          ENAM0 = 0
          let SSP_missileActive = missileActive & 4
          if SSP_missileActive then missile0x = missileX[2] : missile0y = missileY[2] : ENAM0 = 1 : NUSIZ0 = missileNUSIZ[2]                                                               
          
          rem Participant 4 missile (array [3], bit 3) → missile1
          ENAM1 = 0
          let SSP_missileActive = missileActive & 8
          if SSP_missileActive then missile1x = missileX[3] : missile1y = missileY[3] : ENAM1 = 1 : NUSIZ1 = missileNUSIZ[3]                                                               
          return
          
RenderMissilesEvenFrame
          dim RMEF_missileActive = temp4
                    rem Even frame: Render Participants 1-2 missiles
          rem Participant 1 missile (array [0], bit 0) → missile0
          ENAM0 = 0 
          let RMEF_missileActive = missileActive & 1
          if RMEF_missileActive then missile0x = missileX[0] : missile0y = missileY[0] : ENAM0 = 1 : NUSIZ0 = missileNUSIZ[0]                                                              
          
          rem Participant 2 missile (array [1], bit 1) → missile1
          ENAM1 = 0 
          let RMEF_missileActive = missileActive & 2
          if RMEF_missileActive then missile1x = missileX[1] : missile1y = missileY[1] : ENAM1 = 1 : NUSIZ1 = missileNUSIZ[1]                                                              
          return
          
RenderMissiles2Player
          dim RM2P_missileActive = temp4
                    rem 2-player mode: No multiplexing needed, assign missiles directly
          rem Participant 1 (array [0]) missile (missile0, P0 sprite)
          ENAM0 = 0 
          let RM2P_missileActive = missileActive & 1
          if RM2P_missileActive then missile0x = missileX[0] : missile0y = missileY[0] : ENAM0 = 1 : NUSIZ0 = missileNUSIZ[0]                                                              
          
          rem Participant 2 (array [1]) missile (missile1, P1 sprite)
          ENAM1 = 0 
          let RM2P_missileActive = missileActive & 2
          if RM2P_missileActive then missile1x = missileX[1] : missile1y = missileY[1] : ENAM1 = 1 : NUSIZ1 = missileNUSIZ[1]                                                              
          
          return

          rem =================================================================
          rem SET PLAYER SPRITES
          rem =================================================================
          rem Sets colors and graphics for all player sprites.
          rem Colors change based on hurt state and color/B&W switch.
          rem On 7800, Pause button can override Color/B&W setting.
SetPlayerSprites
          dim SPS_charIndex = temp1
          dim SPS_animFrame = temp2
          dim SPS_playerNum = temp3
          rem Set Player 1 color and sprite
          rem Color mode: Use solid player color or dimmer when hurt
          if playerRecoveryFrames[0] > 0 then COLUP0 = ColIndigo(6) : goto Player1ColorDone 
          rem Hurt: dimmer indigo
          let SPS_charIndex = playerChar[0]
          let SPS_animFrame = 0
          let temp1 = SPS_charIndex
          let temp2 = SPS_animFrame
          gosub bank10 LoadCharacterColors
          goto Player1ColorDone 
          rem Normal: solid player color
          
Player1ColorDone

          rem Set sprite reflection based on facing direction (bit 0: 0=left, 1=right)
          asm
          lda playerState
          and #1
          beq .Player1FacingLeft
          lda #0
          sta REFP0
          jmp .Player1ReflectionDone
.Player1FacingLeft
          lda #8
          sta REFP0
.Player1ReflectionDone
          end

          rem Load sprite data from character definition
          let SPS_charIndex = playerChar[0] 
          rem Character index
          let SPS_animFrame = 0 
          rem Animation frame (0=idle, 1=running)
          let SPS_playerNum = 0 
          rem Player number (0=Player 1)
          let temp1 = SPS_charIndex
          let temp2 = SPS_animFrame
          let temp3 = SPS_playerNum
          gosub bank10 LoadCharacterSprite

          rem Set Player 2 color and sprite
          rem Color mode: Use solid player color or dimmer when hurt
          rem NOTE: Multisprite kernel requires _COLUP1 (with underscore) for Player 2 virtual sprite
          if playerRecoveryFrames[1] > 0 then _COLUP1 = ColRed(6) : goto Player2ColorDone 
          rem Hurt: dimmer red
          let SPS_charIndex = playerChar[1]
          let SPS_animFrame = 0
          let temp1 = SPS_charIndex
          let temp2 = SPS_animFrame
          gosub bank10 LoadCharacterColors
          goto Player2ColorDone 
          rem Normal: solid player color
          
Player2ColorDone

          rem Set sprite reflection based on facing direction
          rem NOTE: Multisprite kernel requires _NUSIZ1 (not NewNUSIZ+1) for Player 2 virtual sprite
          asm
          lda playerState+1
          and #1
          beq .Player2FacingLeft
          lda #0
          sta _NUSIZ1
          jmp .Player2ReflectionDone
.Player2FacingLeft
          lda #64
          sta _NUSIZ1
.Player2ReflectionDone
          end

          rem Load sprite data from character definition
          let SPS_charIndex = playerChar[1] 
          rem Character index
          let SPS_animFrame = 0 
          rem Animation frame (0=idle, 1=running)
          let SPS_playerNum = 1 
          rem Player number (1=Player 2)
          let temp1 = SPS_charIndex
          let temp2 = SPS_animFrame
          let temp3 = SPS_playerNum
          gosub bank10 LoadCharacterSprite

          rem Set colors for Players 3 & 4 (multisprite kernel)
          rem Players 3 & 4 have independent COLUP2/COLUP3 registers
          rem No color inheritance issues with proper multisprite implementation
          
          rem Set Player 3 color and sprite (if active)
          if !(controllerStatus & SetQuadtariDetected) then goto SkipPlayer3Sprite
          if selectedChar3 = 255 then goto SkipPlayer3Sprite
          if ! playerHealth[2] then goto SkipPlayer3Sprite
          
          rem Color mode: Use solid player color or dimmer when hurt
          if playerRecoveryFrames[2] > 0 then COLUP2 = ColYellow(6) : goto Player3ColorDone
          rem Hurt: dimmer yellow
          let SPS_charIndex = playerChar[2]
          let SPS_animFrame = 0
          let temp1 = SPS_charIndex
          let temp2 = SPS_animFrame
          gosub bank10 LoadCharacterColors
          goto Player3ColorDone
          rem Normal: solid player color
          
Player3ColorDone

          rem Set sprite reflection based on facing direction
          asm
          lda playerState+2
          and #1
          beq .Player3FacingLeft
          lda #0
          sta NewNUSIZ+2
          jmp .Player3ReflectionDone
.Player3FacingLeft
          lda #64
          sta NewNUSIZ+2
.Player3ReflectionDone
          end

          rem Load sprite data from character definition
          let SPS_charIndex = playerChar[2]
          rem Character index
          let SPS_animFrame = 0
          rem Animation frame (0=idle, 1=running)
          let SPS_playerNum = 2 
          rem Player number (2=Player 3)
          let temp1 = SPS_charIndex
          let temp2 = SPS_animFrame
          let temp3 = SPS_playerNum
          gosub bank10 LoadCharacterSprite
          
SkipPlayer3Sprite

          rem Set Player 4 color and sprite (if active)
          if !(controllerStatus & SetQuadtariDetected) then goto SkipPlayer4Sprite
          if selectedChar4 = 255 then goto SkipPlayer4Sprite
          if ! playerHealth[3] then goto SkipPlayer4Sprite
          
          rem Color mode: Use solid player color or dimmer when hurt
          if playerRecoveryFrames[3] > 0 then COLUP3 = ColGreen(6) : goto Player4ColorDone
          rem Hurt: dimmer green
          let SPS_charIndex = playerChar[3]
          let SPS_animFrame = 0
          let temp1 = SPS_charIndex
          let temp2 = SPS_animFrame
          gosub bank10 LoadCharacterColors
          goto Player4ColorDone
          rem Normal: solid player color
          
Player4ColorDone

          rem Set sprite reflection based on facing direction
          asm
          lda playerState+3
          and #1
          beq .Player4FacingLeft
          lda #0
          sta NewNUSIZ+3
          jmp .Player4ReflectionDone
.Player4FacingLeft
          lda #64
          sta NewNUSIZ+3
.Player4ReflectionDone
          end

          rem Load sprite data from character definition
          let SPS_charIndex = playerChar[3]
          rem Character index
          let SPS_animFrame = 0
          rem Animation frame (0=idle, 1=running)
          let SPS_playerNum = 3 
          rem Player number (3=Player 4)
          let temp1 = SPS_charIndex
          let temp2 = SPS_animFrame
          let temp3 = SPS_playerNum
          gosub bank10 LoadCharacterSprite
          
SkipPlayer4Sprite
          
          return

          rem =================================================================
          rem DISPLAY HEALTH
          rem =================================================================
          rem Shows health status for all active players.
          rem Flashes sprites when health is critically low.
DisplayHealth
          rem Flash Participant 1 sprite (array [0], P0) if health is low (but not during recovery)
          rem Use skip-over pattern to avoid complex || operator
          if playerHealth[0] >= 25 then goto SkipParticipant1Flash
          if playerRecoveryFrames[0] <> 0 then goto SkipParticipant1Flash
          if frame & 8 then player0x = 200 
          rem Hide P0 sprite
SkipParticipant1Flash

          rem Flash Participant 2 sprite (array [1], P1) if health is low
          rem Use skip-over pattern to avoid complex || operator
          if playerHealth[1] >= 25 then goto SkipParticipant2Flash
          if playerRecoveryFrames[1] <> 0 then goto SkipParticipant2Flash
          if frame & 8 then player1x = 200
SkipParticipant2Flash

          rem Flash Player 3 sprite if health is low (but alive)
          if !(controllerStatus & SetQuadtariDetected) then goto SkipPlayer3Flash
          if selectedChar3 = 255 then goto SkipPlayer3Flash
          if ! playerHealth[2] then goto SkipPlayer3Flash
          if playerHealth[2] >= 25 then goto SkipPlayer3Flash
          if playerRecoveryFrames[2] <> 0 then goto SkipPlayer3Flash
          if frame & 8 then player2x = 200 
          rem Player 3 uses player2 sprite
SkipPlayer3Flash

          rem Flash Player 4 sprite if health is low (but alive)
          if !(controllerStatus & SetQuadtariDetected) then goto SkipPlayer4Flash
          if selectedChar4 = 255 then goto SkipPlayer4Flash
          if ! playerHealth[3] then goto SkipPlayer4Flash
          if playerHealth[3] >= 25 then goto SkipPlayer4Flash
          if playerRecoveryFrames[3] <> 0 then goto SkipPlayer4Flash
          if frame & 8 then player3x = 200 
          rem Player 4 uses player3 sprite
SkipPlayer4Flash
          
          return

