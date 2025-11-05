          rem ChaosFight - Source/Routines/PlayerRendering.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem ==========================================================
          rem PLAYER SPRITE RENDERING
          rem ==========================================================
          rem Handles sprite positioning, colors, and graphics for all
          rem   players.

          rem SPRITE ASSIGNMENTS (MULTISPRITE KERNEL):
          rem Participant 1 (array [0]): P0 sprite (player0x/player0y,
          rem   COLUP0)
          rem Participant 2 (array [1]): P1 sprite (player1x/player1y,
          rem   _COLUP1 - virtual sprite)
          rem Participant 3 (array [2]): P2 sprite (player2x/player2y,
          rem   COLUP2)
          rem Participant 4 (array [3]): P3 sprite (player3x/player3y,
          rem   COLUP3)

          rem MISSILE SPRITES:
          rem 2-player mode: missile0 = Participant 1, missile1 =
          rem   Participant 2 (no multiplexing)
          rem 4-player mode: missile0 and missile1 multiplexed between
          rem   all 4 participants (even/odd frames)

          rem AVAILABLE VARIABLES:
          rem   playerX[0-3], playerY[0-3] - Positions
          rem   playerState[0-3] - State flags
          rem   playerRecoveryFrames[0-3] - Hitstun frames
          rem missileActive (bit flags) - Projectile states (bit 0=P0,
          rem   bit 1=P1, bit 2=P2, bit 3=P3)
          rem   missileX[0-3], missileY[0-3] - Projectile positions
          rem   QuadtariDetected, selectedChar3_R, selectedChar4_R
          rem ==========================================================

          rem ==========================================================
          rem SET SPRITE POSITIONS
          rem ==========================================================
          rem Updates hardware sprite position registers for all active
          rem   entities.
SetSpritePositions
          rem Set player sprite positions
          player0x = playerX[0]
          player0y = playerY[0]
          player1x = playerX[1]
          player1y = playerY[1]

          rem Set positions for participants 3 & 4 in 4-player mode
          rem   (multisprite kernel)
          rem Participant 3 (array [2]): P2 sprite (player2x/player2y,
          rem   COLUP2)
          rem Participant 4 (array [3]): P3 sprite (player3x/player3y,
          rem   COLUP3)
          rem Missiles are available for projectiles since participants
          rem   use proper sprites
          
          rem Set Participant 3 position (array [2] → P2 sprite)
          if !(controllerStatus & SetQuadtariDetected) then goto DonePlayer3Position
          if selectedChar3_R = 255 then goto DonePlayer3Position
          if ! playerHealth[2] then goto DonePlayer3Position
          let player2x = playerX[2]
          let player2y = playerY[2]
DonePlayer3Position
          
          rem Set Participant 4 position (array [3] → P3 sprite)
          if !(controllerStatus & SetQuadtariDetected) then goto DonePlayer4Position
          if selectedChar4_R = 255 then goto DonePlayer4Position
          if ! playerHealth[3] then goto DonePlayer4Position
          let player3x = playerX[3]
          let player3y = playerY[3]
DonePlayer4Position
          

          rem Set missile positions for projectiles
          rem Hardware missiles: missile0 and missile1 (only 2 physical
          rem   missiles available on TIA)
          rem In 2-player mode: missile0 = Participant 1, missile1 =
          rem   Participant 2 (no multiplexing needed)
          rem In 4-player mode: Use frame multiplexing to support 4
          rem   logical missiles with 2 hardware missiles:
          rem Even frames: missile0 = Participant 1 (array [0]),
          rem   missile1 = Participant 2 (array [1])
          rem Odd frames: missile0 = Participant 3 (array [2]), missile1
          rem   = Participant 4 (array [3])
          rem Use missileActive bit flags: bit 0 = Participant 1, bit 1
          rem   = Participant 2, bit 2 = Participant 3, bit 3 =
          rem   Participant 4
          
          rem Check if participants 3 or 4 are active (selected and not
          rem   eliminated)
          rem Use this flag instead of QuadtariDetected for missile
          rem   multiplexing
          rem because we only need to multiplex when participants 3 or 4
          rem   are actually in the game
          if !(controllerStatus & SetPlayers34Active) then goto RenderMissiles2Player
          
          rem 4-player mode: Use frame multiplexing
          dim SSP_frameParity = temp6
          dim SSP_missileActive = temp4
          dim SSP_characterType = temp5
          rem Shared temp5 for character type lookups in this code path
          let SSP_frameParity = frame & 1
          rem 0 = even frame (Participants 1-2), 1 = odd frame
          rem   (Participants 3-4)
          
          if SSP_frameParity = 0 then goto RenderMissilesEvenFrame
          
                    rem Odd frame: Render Participants 3-4 missiles
          rem Participant 3 missile (array [2], bit 2) → missile0
          ENAM0 = 0
          missile0height = 0
          rem Clear missile height first
          let SSP_missileActive = missileActive & 4
          if SSP_missileActive then goto RenderMissile0P3
          rem Check for RoboTito stretch missile if no projectile missile
          gosub RenderRoboTitoStretchMissile0
          rem If no stretch missile rendered, ENAM0 remains 0 (no blank
          rem   missile)
          goto RenderMissile1P4
RenderMissile0P3
          rem Set missile 0 position and size for Participant 3
          missile0x = missileX[2]
          missile0y = missileY_R[2]
          ENAM0 = 1
          NUSIZ0 = missileNUSIZ[2]
          rem Set missile height from character data (Issue #595)
          let SSP_characterType = playerChar[2]
          missile0height = CharacterMissileHeights[SSP_characterType]
          
RenderMissile1P4
          rem Participant 4 missile (array [3], bit 3) → missile1
          ENAM1 = 0
          missile1height = 0
          rem Clear missile height first
          let SSP_missileActive = missileActive & 8
          if SSP_missileActive then goto RenderMissile1P4Active
          rem Check for RoboTito stretch missile if no projectile missile
          gosub RenderRoboTitoStretchMissile1
          rem If no stretch missile rendered, ENAM1 remains 0 (no blank
          rem   missile)
          return
RenderMissile1P4Active
          rem Set missile 1 position and size for Participant 4
          missile1x = missileX[3]
          missile1y = missileY_R[3]
          ENAM1 = 1
          NUSIZ1 = missileNUSIZ[3]
          rem Set missile height from character data (Issue #595)
          let SSP_characterType = playerChar[3]
          missile1height = CharacterMissileHeights[SSP_characterType]
          return
          
RenderMissilesEvenFrame
          dim RMEF_missileActive = temp4
          dim RMEF_characterType = temp5
          rem Shared temp5 for character type lookups in this code path
                    rem Even frame: Render Participants 1-2 missiles
          rem Participant 1 missile (array [0], bit 0) → missile0
          ENAM0 = 0 
          missile0height = 0
          rem Clear missile height first
          let RMEF_missileActive = missileActive & 1
          if RMEF_missileActive then goto RenderMissile0P1
          rem Check for RoboTito stretch missile if no projectile missile
          gosub RenderRoboTitoStretchMissile0
          rem If no stretch missile rendered, ENAM0 remains 0 (no blank
          rem   missile)
          goto RenderMissile1P2
RenderMissile0P1
          rem Set missile 0 position and size for Participant 1
          missile0x = missileX[0]
          missile0y = missileY_R[0]
          ENAM0 = 1
          NUSIZ0 = missileNUSIZ[0]
          rem Set missile height from character data (Issue #595)
          let RMEF_characterType = playerChar[0]
          missile0height = CharacterMissileHeights[RMEF_characterType]
          
RenderMissile1P2
          rem Participant 2 missile (array [1], bit 1) → missile1
          ENAM1 = 0 
          missile1height = 0
          rem Clear missile height first
          let RMEF_missileActive = missileActive & 2
          if RMEF_missileActive then goto RenderMissile1P2Active
          rem Check for RoboTito stretch missile if no projectile missile
          gosub RenderRoboTitoStretchMissile1
          rem If no stretch missile rendered, ENAM1 remains 0 (no blank
          rem   missile)
          return
RenderMissile1P2Active
          rem Set missile 1 position and size for Participant 2
          missile1x = missileX[1]
          missile1y = missileY_R[1]
          ENAM1 = 1
          NUSIZ1 = missileNUSIZ[1]
          rem Set missile height from character data (Issue #595)
          let RMEF_characterType = playerChar[1]
          missile1height = CharacterMissileHeights[RMEF_characterType]
          return
          
RenderMissiles2Player
          dim RM2P_missileActive = temp4
          dim RM2P_characterType = temp5
          rem Shared temp5 for character type lookups in this code path
          rem 2-player mode: No multiplexing needed, assign missiles
          rem   directly
          rem Participant 1 (array [0]) missile (missile0, P0 sprite)
          ENAM0 = 0 
          missile0height = 0
          rem Clear missile height first
          let RM2P_missileActive = missileActive & 1
          if RM2P_missileActive then goto RenderMissile0P1_2P
          rem Check for RoboTito stretch missile if no projectile missile
          gosub RenderRoboTitoStretchMissile0
          rem If no stretch missile rendered, ENAM0 remains 0 (no blank
          rem   missile)
          goto RenderMissile1P2_2P
RenderMissile0P1_2P
          rem Set missile 0 position and size for Participant 1 (2-player
          rem   mode)
          missile0x = missileX[0]
          missile0y = missileY_R[0]
          ENAM0 = 1
          NUSIZ0 = missileNUSIZ[0]
          rem Set missile height from character data (Issue #595)
          let RM2P_characterType = playerChar[0]
          missile0height = CharacterMissileHeights[RM2P_characterType]
          
RenderMissile1P2_2P
          rem Participant 2 (array [1]) missile (missile1, P1 sprite)
          ENAM1 = 0 
          missile1height = 0
          rem Clear missile height first
          let RM2P_missileActive = missileActive & 2
          if RM2P_missileActive then goto RenderMissile1P2_2PActive
          rem Check for RoboTito stretch missile if no projectile missile
          gosub RenderRoboTitoStretchMissile1
          rem If no stretch missile rendered, ENAM1 remains 0 (no blank
          rem   missile)
          return
RenderMissile1P2_2PActive
          rem Set missile 1 position and size for Participant 2 (2-player
          rem   mode)
          missile1x = missileX[1]
          missile1y = missileY_R[1]
          ENAM1 = 1
          NUSIZ1 = missileNUSIZ[1]
          rem Set missile height from character data (Issue #595)
          let RM2P_characterType = playerChar[1]
          missile1height = CharacterMissileHeights[RM2P_characterType]
          return
          
          rem ==========================================================
          rem RENDER ROBOTITO STRETCH MISSILES
          rem ==========================================================
          rem Helper functions to render RoboTito stretch visual missiles
          rem Only rendered if player is RoboTito, stretching upward
          rem   (not latched), and no projectile missile active
          
RenderRoboTitoStretchMissile0
          dim RRTM_playerIndex = temp1
          dim RRTM_isStretching = temp2
          dim RRTM_stretchHeight = temp3
          dim RRTM_frameParity = temp4
          rem Determine which player uses missile0 based on frame parity
          if !(controllerStatus & SetPlayers34Active) then RRTM_CheckPlayer0
          rem 2-player mode: Player 0 uses missile0
          let RRTM_frameParity = frame & 1
          if RRTM_frameParity = 0 then RRTM_CheckPlayer0
          rem Even frame: Player 0 uses missile0
          rem Odd frame: Player 2 uses missile0
          let RRTM_playerIndex = 2
          goto RRTM_CheckRoboTito
RRTM_CheckPlayer0
          let RRTM_playerIndex = 0
RRTM_CheckRoboTito
          rem Check if player is RoboTito
          if playerChar[RRTM_playerIndex] = CharRoboTito then RRTM_IsRoboTito
          return
          rem Not RoboTito, no stretch missile
RRTM_IsRoboTito
          rem Check if stretching upward (not latched, ActionJumping
          rem   animation = 10)
          if (characterStateFlags_R[RRTM_playerIndex] & 1) then return
          rem Latched to ceiling, no stretch missile
          let RRTM_isStretching = playerState[RRTM_playerIndex]
          let RRTM_isStretching = RRTM_isStretching & 240
          rem Mask bits 4-7 (animation state, value 240 = %11110000)
          let RRTM_isStretching = RRTM_isStretching / 16
          rem Shift right by 4 (divide by 16) to get animation state
          rem   (0-15)
          if RRTM_isStretching = 10 then RRTM_IsStretching
          return
          rem Not in stretching animation (ActionJumping = 10), no
          rem   stretch missile
RRTM_IsStretching
          
          rem Get stretch height and render if > 0
          let RRTM_stretchHeight = missileStretchHeight_R[RRTM_playerIndex]
          if RRTM_stretchHeight <= 0 then return
          rem No height, no stretch missile
          
          rem Render stretch missile: position at player, set height
          missile0x = playerX[RRTM_playerIndex]
          missile0y = playerY[RRTM_playerIndex]
          missile0height = RRTM_stretchHeight
          ENAM0 = 1
          NUSIZ0 = 0
          rem 1x size (NUSIZ bits 4-6 = 00)
          return
          
RenderRoboTitoStretchMissile1
          dim RRTM1_playerIndex = temp1
          dim RRTM1_isStretching = temp2
          dim RRTM1_stretchHeight = temp3
          dim RRTM1_frameParity = temp4
          rem Determine which player uses missile1 based on frame parity
          if !(controllerStatus & SetPlayers34Active) then RRTM1_CheckPlayer1
          rem 2-player mode: Player 1 uses missile1
          let RRTM1_frameParity = frame & 1
          if RRTM1_frameParity = 0 then RRTM1_CheckPlayer1
          rem Even frame: Player 1 uses missile1
          rem Odd frame: Player 3 uses missile1
          let RRTM1_playerIndex = 3
          goto RRTM1_CheckRoboTito
RRTM1_CheckPlayer1
          let RRTM1_playerIndex = 1
RRTM1_CheckRoboTito
          rem Check if player is RoboTito
          if playerChar[RRTM1_playerIndex] = CharRoboTito then RRTM1_IsRoboTito
          return
          rem Not RoboTito, no stretch missile
RRTM1_IsRoboTito
          rem Check if stretching upward (not latched, ActionJumping
          rem   animation = 10)
          if (characterStateFlags_R[RRTM1_playerIndex] & 1) then return
          rem Latched to ceiling, no stretch missile
          let RRTM1_isStretching = playerState[RRTM1_playerIndex]
          let RRTM1_isStretching = RRTM1_isStretching & 240
          rem Mask bits 4-7 (animation state, value 240 = %11110000)
          let RRTM1_isStretching = RRTM1_isStretching / 16
          rem Shift right by 4 (divide by 16) to get animation state
          rem   (0-15)
          if RRTM1_isStretching = 10 then RRTM1_IsStretching
          return
          rem Not in stretching animation (ActionJumping = 10), no
          rem   stretch missile
RRTM1_IsStretching
          
          rem Get stretch height and render if > 0
          let RRTM1_stretchHeight = missileStretchHeight_R[RRTM1_playerIndex]
          if RRTM1_stretchHeight <= 0 then return
          rem No height, no stretch missile
          
          rem Render stretch missile: position at player, set height
          missile1x = playerX[RRTM1_playerIndex]
          missile1y = playerY[RRTM1_playerIndex]
          missile1height = RRTM1_stretchHeight
          ENAM1 = 1
          NUSIZ1 = 0
          rem 1x size (NUSIZ bits 4-6 = 00)
          return

          rem ==========================================================
          rem SET PLAYER SPRITES
          rem ==========================================================
          rem Sets colors and graphics for all player sprites.
          rem Colors change based on hurt state and color/B&W switch.
          rem On 7800, Pause button can override Color/B&W setting.
SetPlayerSprites
          dim SPS_charIndex = temp1
          dim SPS_animFrame = temp2
          dim SPS_playerNum = temp3
          dim SPS_isHurt = temp4
          rem Set Player 1 color and sprite
          rem Use LoadCharacterColors for consistent color handling
          rem   across TV modes
          let SPS_charIndex = playerChar[0]
          let SPS_animFrame = 0
          let SPS_isHurt = playerRecoveryFrames[0] > 0
          let SPS_playerNum = 0
          rem Set LoadCharacterColors aliases for cross-bank call
          let LoadCharacterColors_isHurt = SPS_isHurt
          rem LoadCharacterColors_playerNumber already set via
          rem   SPS_playerNum alias
          let LoadCharacterColors_isFlashing = 0
          let LoadCharacterColors_flashingMode = 0
          gosub bank10 LoadCharacterColors
          goto Player1ColorDone
          
Player1ColorDone

          rem Set sprite reflection based on facing direction (bit 3:
          rem   0=left, 1=right) - matches REFP0 bit 3 for direct copy
          asm
            lda playerState
            and #PlayerStateBitFacing
            sta REFP0
end

          rem Load sprite data from character definition
          let currentCharacter = playerChar[0] 
          rem Character index
          let SPS_animFrame = 0 
          rem Animation frame (0=idle, 1=running)
          let SPS_playerNum = 0 
          rem Player number (0=Player 1)
          rem temp2, temp3 already set via aliases (SPS_animFrame,
          rem   SPS_playerNum)
          gosub bank10 LoadCharacterSprite

          rem Set Player 2 color and sprite
          rem Use LoadCharacterColors for consistent color handling
          rem   across TV modes
          rem NOTE: Multisprite kernel requires _COLUP1 (with
          rem   underscore) for Player 2 virtual sprite
          let SPS_charIndex = playerChar[1]
          let SPS_animFrame = 0
          let SPS_isHurt = playerRecoveryFrames[1] > 0
          let SPS_playerNum = 1
          rem Set LoadCharacterColors aliases for cross-bank call
          let LoadCharacterColors_isHurt = SPS_isHurt
          rem LoadCharacterColors_playerNumber already set via
          rem   SPS_playerNum alias
          let LoadCharacterColors_isFlashing = 0
          let LoadCharacterColors_flashingMode = 0
          gosub bank10 LoadCharacterColors
          goto Player2ColorDone
          
Player2ColorDone

          rem Set sprite reflection based on facing direction
          rem NOTE: Multisprite kernel requires _NUSIZ1 (not NewNUSIZ+1)
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
          let currentCharacter = playerChar[1] 
          rem Character index
          let SPS_animFrame = 0 
          rem Animation frame (0=idle, 1=running)
          let SPS_playerNum = 1 
          rem Player number (1=Player 2)
          rem temp2, temp3 already set via aliases (SPS_animFrame,
          rem   SPS_playerNum)
          gosub bank10 LoadCharacterSprite

          rem Set colors for Players 3 & 4 (multisprite kernel)
          rem Players 3 & 4 have independent COLUP2/COLUP3 registers
          rem No color inheritance issues with proper multisprite
          rem   implementation
          
                    rem Set Player 3 color and sprite (if active)
          if !(controllerStatus & SetQuadtariDetected) then goto DonePlayer3Sprite
          if selectedChar3_R = 255 then goto DonePlayer3Sprite
          if ! playerHealth[2] then goto DonePlayer3Sprite
          
          rem Use LoadCharacterColors for consistent color handling
          rem   across TV modes
          let SPS_charIndex = playerChar[2]
          let SPS_animFrame = 0
          let SPS_isHurt = playerRecoveryFrames[2] > 0
          let SPS_playerNum = 2
          rem Set LoadCharacterColors aliases for cross-bank call
          let LoadCharacterColors_isHurt = SPS_isHurt
          rem LoadCharacterColors_playerNumber already set via
          rem   SPS_playerNum alias
          let LoadCharacterColors_isFlashing = 0
          let LoadCharacterColors_flashingMode = 0
          gosub bank10 LoadCharacterColors
          goto Player3ColorDone
          
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
          let currentCharacter = playerChar[2]
          rem Character index
          let SPS_animFrame = 0
          rem Animation frame (0=idle, 1=running)
          let SPS_playerNum = 2 
          rem Player number (2=Player 3)
          rem temp2, temp3 already set via aliases (SPS_animFrame,
          rem   SPS_playerNum)
          gosub bank10 LoadCharacterSprite
          
DonePlayer3Sprite

          rem Set Player 4 color and sprite (if active)
          if !(controllerStatus & SetQuadtariDetected) then goto DonePlayer4Sprite
          if selectedChar4_R = 255 then goto DonePlayer4Sprite
          if ! playerHealth[3] then goto DonePlayer4Sprite
          
          rem Use LoadCharacterColors for consistent color handling
          rem   across TV modes
          rem Player 4: Turquoise (SECAM maps to Green), hurt handled by
          rem   LoadCharacterColors
          let SPS_charIndex = playerChar[3]
          let SPS_animFrame = 0
          let SPS_isHurt = playerRecoveryFrames[3] > 0
          let SPS_playerNum = 3
          rem Set LoadCharacterColors aliases for cross-bank call
          let LoadCharacterColors_isHurt = SPS_isHurt
          rem LoadCharacterColors_playerNumber already set via
          rem   SPS_playerNum alias
          let LoadCharacterColors_isFlashing = 0
          let LoadCharacterColors_flashingMode = 0
          gosub bank10 LoadCharacterColors
          goto Player4ColorDone
          
Player4ColorDone

          rem Set sprite reflection based on facing direction
          rem NUSIZ reflection uses bit 6 - preserve other bits (size,
          rem   etc.)
          asm
            lda NewNUSIZ+3
            and #NUSIZMaskReflection
            sta NewNUSIZ+3
            lda playerState+3
            and #PlayerStateBitFacing
            beq .Player4ReflectionDone
            lda NewNUSIZ+3
            ora #PlayerStateBitFacingNUSIZ
            sta NewNUSIZ+3
.Player4ReflectionDone
end

          rem Load sprite data from character definition
          let currentCharacter = playerChar[3]
          rem Character index
          let SPS_animFrame = 0
          rem Animation frame (0=idle, 1=running)
          let SPS_playerNum = 3 
          rem Player number (3=Player 4)
          rem temp2, temp3 already set via aliases (SPS_animFrame,
          rem   SPS_playerNum)
          gosub bank10 LoadCharacterSprite
          
DonePlayer4Sprite
          
          return

          rem ==========================================================
          rem DISPLAY HEALTH
          rem ==========================================================
          rem Shows health status for all active players.
          rem Flashes sprites when health is critically low.
DisplayHealth
          rem Flash Participant 1 sprite (array [0], P0) if health is
          rem   low (but not during recovery)
          rem Use skip-over pattern to avoid complex || operator
          if playerHealth[0] >= 25 then goto DoneParticipant1Flash
          if playerRecoveryFrames[0] = 0 then FlashParticipant1
          goto DoneParticipant1Flash
FlashParticipant1
          if frame & 8 then player0x = 200 
          rem Hide P0 sprite
DoneParticipant1Flash

          rem Flash Participant 2 sprite (array [1], P1) if health is
          rem   low
          rem Use skip-over pattern to avoid complex || operator
          if playerHealth[1] >= 25 then goto DoneParticipant2Flash
          if playerRecoveryFrames[1] = 0 then FlashParticipant2
          goto DoneParticipant2Flash
FlashParticipant2
          if frame & 8 then player1x = 200
DoneParticipant2Flash

          rem Flash Player 3 sprite if health is low (but alive)
          if !(controllerStatus & SetQuadtariDetected) then goto DonePlayer3Flash
          if selectedChar3_R = 255 then goto DonePlayer3Flash
          if ! playerHealth[2] then goto DonePlayer3Flash
          if playerHealth[2] >= 25 then goto DonePlayer3Flash
          if playerRecoveryFrames[2] = 0 then FlashPlayer3
          goto DonePlayer3Flash
FlashPlayer3
          if frame & 8 then player2x = 200 
          rem Player 3 uses player2 sprite
DonePlayer3Flash

          rem Flash Player 4 sprite if health is low (but alive)
          if !(controllerStatus & SetQuadtariDetected) then goto DonePlayer4Flash
          if selectedChar4_R = 255 then goto DonePlayer4Flash
          if ! playerHealth[3] then goto DonePlayer4Flash
          if playerHealth[3] >= 25 then goto DonePlayer4Flash
          if playerRecoveryFrames[3] = 0 then FlashPlayer4
          goto DonePlayer4Flash
FlashPlayer4
          if frame & 8 then player3x = 200 
          rem Player 4 uses player3 sprite
DonePlayer4Flash
          
          return

