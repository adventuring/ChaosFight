          rem ChaosFight - Source/Routines/PlayerRendering.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

SetSpritePositions
          rem Player Sprite Rendering
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
          rem
          rem   bit 1=P1, bit 2=P2, bit 3=P3)
          rem   missileX[0-3], missileY[0-3] - Projectile positions
          rem   controllerStatus flags (SetQuadtariDetected, SetPlayers34Active)
          rem Set Sprite Positions
          rem Update hardware sprite position registers for all active players and missiles.
          rem
          rem Input: playerX[], playerY[] (global arrays) = player
          rem positions, missileX[] (global array) = missile X
          rem positions, missileY_R[] (global SCRAM array) = missile Y
          rem positions, missileActive (global) = missile active flags,
          rem playerCharacter[] (global array) = character types,
          rem controllerStatus (global) = controller state,
          rem playerHealth[] (global array) = player
          rem health, frame (global) = frame counter, missileNUSIZ[]
          rem (global array) = missile size registers,
          rem CharacterMissileHeights[] (global data table) = missile
          rem heights, characterStateFlags_R[] (global SCRAM array) =
          rem character state flags, playerState[] (global array) =
          rem player states, missileStretchHeight_R[] (global SCRAM
          rem array) = stretch missile heights
          rem
          rem Output: All sprite positions set, missile positions set
          rem with frame multiplexing in 4-player mode
          rem
          rem Mutates: player0x, player0y, player1x, player1y, player2x,
          rem player2y, player3x, player3y (TIA registers) = sprite
          rem positions, missile0x, missile0y, missile1x, missile1y (TIA
          rem registers) = missile positions, ENAM0, ENAM1 (TIA
          rem registers) = missile enable flags, missile0height,
          rem missile1height (TIA registers) = missile heights, NUSIZ0,
          rem NUSIZ1 (TIA registers) = missile size registers,
          rem temp1-temp6 (used for calculations)
          rem
          rem Called Routines: RenderRoboTitoStretchMissile0 - renders
          rem RoboTito stretch missile for missile0,
          rem RenderRoboTitoStretchMissile1 - renders RoboTito stretch
          rem missile for missile1
          rem
          rem Constraints: 4-player mode uses frame multiplexing (even
          rem frames = P1/P2, odd frames = P3/P4)
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
          if playerCharacter[2] = NoCharacter then goto DonePlayer3Position
          if ! playerHealth[2] then goto DonePlayer3Position
          player2x = playerX[2]
          player2y = playerY[2]
DonePlayer3Position
          
          rem Set Participant 4 position (array [3] → P3 sprite)
          
          if !(controllerStatus & SetQuadtariDetected) then goto DonePlayer4Position
          if playerCharacter[3] = NoCharacter then goto DonePlayer4Position
          if ! playerHealth[3] then goto DonePlayer4Position
          player3x = playerX[3]
          player3y = playerY[3]
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
          rem are actually in the game
          if !(controllerStatus & SetPlayers34Active) then goto RenderMissiles2Player
          
          rem 4-player mode: Use frame multiplexing
          let temp6 = frame & 1
          rem Shared temp5 for character type lookups in this code path
          rem 0 = even frame (Participants 1-2), 1 = odd frame
          rem   (Participants 3-4)
          
          if temp6 = 0 then goto RenderMissilesEvenFrame
          
                    rem Odd frame: Render Participants 3-4 missiles
          rem Participant 3 missile (array [2], bit 2) → missile0
          ENAM0 = 0
          missile0height = 0
          let temp4 = missileActive & 4
          rem Clear missile height first
          if temp4 then goto RenderMissile0P3
          gosub RenderRoboTitoStretchMissile0
          rem Check for RoboTito stretch missile if no projectile missile
          rem If no stretch missile rendered, ENAM0 remains 0 (no blank
          goto RenderMissile1P4
          rem   missile)
RenderMissile0P3
          rem Set missile 0 position and size for Participant 3
          missile0x = missileX[2]
          missile0y = missileY_R[2]
          ENAM0 = 1
          NUSIZ0 = missileNUSIZ_R[2]
          let temp5 = playerCharacter[2]
          rem Set missile height from character data (Issue #595)
          missile0height = CharacterMissileHeights[temp5]
          
RenderMissile1P4
          rem Participant 4 missile (array [3], bit 3) → missile1
          ENAM1 = 0
          missile1height = 0
          let temp4 = missileActive & 8
          rem Clear missile height first
          if temp4 then goto RenderMissile1P4Active
          gosub RenderRoboTitoStretchMissile1
          rem Check for RoboTito stretch missile if no projectile missile
          rem If no stretch missile rendered, ENAM1 remains 0 (no blank
          rem   missile)
          return
RenderMissile1P4Active
          rem Set missile 1 position and size for Participant 4
          missile1x = missileX[3]
          missile1y = missileY_R[3]
          ENAM1 = 1
          NUSIZ1 = missileNUSIZ_R[3]
          let temp5 = playerCharacter[3]
          rem Set missile height from character data (Issue #595)
          missile1height = CharacterMissileHeights[temp5]
          return
          
RenderMissilesEvenFrame
          rem Shared temp5 for character type lookups in this code path
                    rem Even frame: Render Participants 1-2 missiles
          rem Participant 1 missile (array [0], bit 0) → missile0
          ENAM0 = 0 
          missile0height = 0
          let temp4 = missileActive & 1
          rem Clear missile height first
          if temp4 then goto RenderMissile0P1
          gosub RenderRoboTitoStretchMissile0
          rem Check for RoboTito stretch missile if no projectile missile
          rem If no stretch missile rendered, ENAM0 remains 0 (no blank
          goto RenderMissile1P2
          rem   missile)
RenderMissile0P1
          rem Set missile 0 position and size for Participant 1
          missile0x = missileX[0]
          missile0y = missileY_R[0]
          ENAM0 = 1
          NUSIZ0 = missileNUSIZ_R[0]
          let temp5 = playerCharacter[0]
          rem Set missile height from character data (Issue #595)
          missile0height = CharacterMissileHeights[temp5]
          
RenderMissile1P2
          rem Participant 2 missile (array [1], bit 1) → missile1
          ENAM1 = 0 
          missile1height = 0
          let temp4 = missileActive & 2
          rem Clear missile height first
          if temp4 then goto RenderMissile1P2Active
          gosub RenderRoboTitoStretchMissile1
          rem Check for RoboTito stretch missile if no projectile missile
          rem If no stretch missile rendered, ENAM1 remains 0 (no blank
          rem   missile)
          return
RenderMissile1P2Active
          rem Set missile 1 position and size for Participant 2
          missile1x = missileX[1]
          missile1y = missileY_R[1]
          ENAM1 = 1
          NUSIZ1 = missileNUSIZ_R[1]
          let temp5 = playerCharacter[1]
          rem Set missile height from character data (Issue #595)
          missile1height = CharacterMissileHeights[temp5]
          return
          
RenderMissiles2Player
          rem Shared temp5 for character type lookups in this code path
          rem 2-player mode: No multiplexing needed, assign missiles
          rem   directly
          rem Participant 1 (array [0]) missile (missile0, P0 sprite)
          ENAM0 = 0 
          missile0height = 0
          let temp4 = missileActive & 1
          rem Clear missile height first
          if temp4 then goto RenderMissile0P1_2P
          gosub RenderRoboTitoStretchMissile0
          rem Check for RoboTito stretch missile if no projectile missile
          rem If no stretch missile rendered, ENAM0 remains 0 (no blank
          goto RenderMissile1P2_2P
          rem   missile)
RenderMissile0P1_2P
          rem Set missile 0 position and size for Participant 1
          rem (2-player
          rem   mode)
          missile0x = missileX[0]
          missile0y = missileY_R[0]
          ENAM0 = 1
          NUSIZ0 = missileNUSIZ_R[0]
          let temp5 = playerCharacter[0]
          rem Set missile height from character data (Issue #595)
          missile0height = CharacterMissileHeights[temp5]
          
RenderMissile1P2_2P
          rem Participant 2 (array [1]) missile (missile1, P1 sprite)
          ENAM1 = 0 
          missile1height = 0
          let temp4 = missileActive & 2
          rem Clear missile height first
          if temp4 then goto RenderMissile1P2_2PActive
          gosub RenderRoboTitoStretchMissile1
          rem Check for RoboTito stretch missile if no projectile missile
          rem If no stretch missile rendered, ENAM1 remains 0 (no blank
          rem   missile)
          return
RenderMissile1P2_2PActive
          rem Set missile 1 position and size for Participant 2
          rem (2-player
          rem   mode)
          missile1x = missileX[1]
          missile1y = missileY_R[1]
          ENAM1 = 1
          NUSIZ1 = missileNUSIZ_R[1]
          let temp5 = playerCharacter[1]
          rem Set missile height from character data (Issue #595)
          missile1height = CharacterMissileHeights[temp5]
          return
          
RenderRoboTitoStretchMissile0
          rem
          rem Render Robotito Stretch Missiles
          rem Helper functions to render RoboTito stretch visual
          rem missiles
          rem Only rendered if player is RoboTito, stretching upward
          rem   (not latched), and no projectile missile active
          
          rem Renders RoboTito stretch visual missile for missile0 (only
          rem if RoboTito, stretching, and no projectile missile)
          rem
          rem Input: controllerStatus (global) = controller state, frame
          rem (global) = frame counter, playerCharacter[] (global array) =
          rem character types, characterStateFlags_R[] (global SCRAM
          rem array) = character state flags, playerState[] (global
          rem array) = player states, missileStretchHeight_R[] (global
          rem SCRAM array) = stretch missile heights, playerX[],
          rem playerY[] (global arrays) = player positions, CharacterRoboTito
          rem (global constant) = RoboTito character index
          rem
          rem Output: missile0 rendered as stretch missile if conditions
          rem met
          rem
          rem Mutates: temp1-temp4 (used for calculations), missile0x,
          rem missile0y (TIA registers) = missile position,
          rem missile0height (TIA register) = missile height, ENAM0 (TIA
          rem register) = missile enable flag, NUSIZ0 (TIA register) =
          rem missile size
          rem
          rem Called Routines: None
          rem
          rem Constraints: Only renders if player is RoboTito,
          rem stretching upward (not latched, ActionJumping=10), and
          rem stretch height > 0. Frame multiplexing determines which
          rem player uses missile0
          if !(controllerStatus & SetPlayers34Active) then RRTM_CheckPlayer0
          rem Determine which player uses missile0 based on frame parity
          let temp4 = frame & 1
          rem 2-player mode: Player 0 uses missile0
          if temp4 = 0 then RRTM_CheckPlayer0
          rem Even frame: Player 0 uses missile0
          let temp1 = 2
          rem Odd frame: Player 2 uses missile0
          goto RRTM_CheckRoboTito
RRTM_CheckPlayer0
          let temp1 = 0
RRTM_CheckRoboTito
          if playerCharacter[temp1] = CharacterRoboTito then RRTM_IsRoboTito
          rem Check if player is RoboTito
          return
RRTM_IsRoboTito
          rem Not RoboTito, no stretch missile
          rem Check if stretching upward (not latched, ActionJumping
          if (characterStateFlags_R[temp1] & 1) then return
          rem animation = 10)
          let temp2 = playerState[temp1]
          rem Latched to ceiling, no stretch missile
          let temp2 = temp2 & 240
          rem Mask bits 4-7 (animation state, value 240 = %11110000)
          let temp2 = temp2 / 16
          rem Shift right by 4 (divide by 16) to get animation state
          if temp2 = 10 then RRTM_IsStretching
          rem   (0-15)
          return
RRTM_IsStretching
          rem Not in stretching animation (ActionJumping = 10), no
          rem   stretch missile
          let temp3 = missileStretchHeight_R[temp1]
          rem Get stretch height and render if > 0
          if temp3 <= 0 then return
          rem No height, no stretch missile
          
          rem Render stretch missile: position at player, set height
          missile0x = playerX[temp1]
          missile0y = playerY[temp1]
          missile0height = temp3
          ENAM0 = 1
          NUSIZ0 = 0
          rem 1x size (NUSIZ bits 4-6 = 00)
          return
          
RenderRoboTitoStretchMissile1
          rem Renders RoboTito stretch visual missile for missile1 (only
          rem if RoboTito, stretching, and no projectile missile)
          rem
          rem Input: controllerStatus (global) = controller state, frame
          rem (global) = frame counter, playerCharacter[] (global array) =
          rem character types, characterStateFlags_R[] (global SCRAM
          rem array) = character state flags, playerState[] (global
          rem array) = player states, missileStretchHeight_R[] (global
          rem SCRAM array) = stretch missile heights, playerX[],
          rem playerY[] (global arrays) = player positions, CharacterRoboTito
          rem (global constant) = RoboTito character index
          rem
          rem Output: missile1 rendered as stretch missile if conditions
          rem met
          rem
          rem Mutates: temp1-temp4 (used for calculations), missile1x,
          rem missile1y (TIA registers) = missile position,
          rem missile1height (TIA register) = missile height, ENAM1 (TIA
          rem register) = missile enable flag, NUSIZ1 (TIA register) =
          rem missile size
          rem
          rem Called Routines: None
          rem
          rem Constraints: Only renders if player is RoboTito,
          rem stretching upward (not latched, ActionJumping=10), and
          rem stretch height > 0. Frame multiplexing determines which
          rem player uses missile1
          if !(controllerStatus & SetPlayers34Active) then RRTM1_CheckPlayer1
          rem Determine which player uses missile1 based on frame parity
          let temp4 = frame & 1
          rem 2-player mode: Player 1 uses missile1
          if temp4 = 0 then RRTM1_CheckPlayer1
          rem Even frame: Player 1 uses missile1
          let temp1 = 3
          rem Odd frame: Player 3 uses missile1
          goto RRTM1_CheckRoboTito
RRTM1_CheckPlayer1
          let temp1 = 1
RRTM1_CheckRoboTito
          if playerCharacter[temp1] = CharacterRoboTito then RRTM1_IsRoboTito
          rem Check if player is RoboTito
          return
RRTM1_IsRoboTito
          rem Not RoboTito, no stretch missile
          rem Check if stretching upward (not latched, ActionJumping
          if (characterStateFlags_R[temp1] & 1) then return
          rem animation = 10)
          let temp2 = playerState[temp1]
          rem Latched to ceiling, no stretch missile
          let temp2 = temp2 & 240
          rem Mask bits 4-7 (animation state, value 240 = %11110000)
          let temp2 = temp2 / 16
          rem Shift right by 4 (divide by 16) to get animation state
          if temp2 = 10 then RRTM1_IsStretching
          rem   (0-15)
          return
RRTM1_IsStretching
          rem Not in stretching animation (ActionJumping = 10), no
          rem   stretch missile
          
          let temp3 = missileStretchHeight_R[temp1]
          rem Get stretch height and render if > 0
          if temp3 <= 0 then return
          rem No height, no stretch missile
          
          rem Render stretch missile: position at player, set height
          missile1x = playerX[temp1]
          missile1y = playerY[temp1]
          missile1height = temp3
          ENAM1 = 1
          NUSIZ1 = 0
          rem 1x size (NUSIZ bits 4-6 = 00)
          return

SetPlayerSprites
          rem
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
          rem Called Routines: LoadCharacterColors (bank16) - loads
          rem player colors, LoadCharacterSprite (bank10) - loads sprite
          rem graphics
          rem
          rem Constraints: Multisprite kernel requires _COLUP1 and
          rem _NUSIZ1 for Player 2 virtual sprite. Players 3/4 only
          rem rendered if Quadtari detected and selected
          rem Set Player 1 color and sprite
          rem Use LoadCharacterColors for consistent color handling
          rem Player index
          let currentPlayer = 0
          rem Hurt flag (non-zero = recovering)
          let temp2 = playerRecoveryFrames[0]
          rem Guard flag (non-zero = guarding)
          let temp3 = playerState[0] & PlayerStateBitGuarding
          gosub LoadCharacterColors bank16
          COLUP0 = temp6
Player1ColorDone

          rem Set sprite reflection based on facing direction (bit 3:
          rem   0=left, 1=right) - matches REFP0 bit 3 for direct copy
          asm
            lda playerState
            and #PlayerStateBitFacing
            sta REFP0
end

          let currentCharacter = playerCharacter[0]
          rem Load sprite data from character definition
          let temp2 = 0
          rem Animation frame (0 = idle)
          let temp3 = 0
          rem Animation action (0 = idle)
          gosub LoadCharacterSprite bank16

          rem Set Player 2 color and sprite
          rem Use LoadCharacterColors for consistent color handling
          rem NOTE: Multi-sprite kernel requires _COLUP1 (with
          rem Player index
          let currentPlayer = 1
          rem Hurt flag (non-zero = recovering)
          let temp2 = playerRecoveryFrames[1]
          rem Guard flag (non-zero = guarding)
          let temp3 = playerState[1] & PlayerStateBitGuarding
          gosub LoadCharacterColors bank16
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

          let currentCharacter = playerCharacter[1]
          rem Load sprite data from character definition
          temp2 = 0
          rem Animation frame (0 = idle)
          temp3 = 0
          rem Animation action (0 = idle)
          gosub LoadCharacterSprite bank16

          rem Set colors for Players 3 & 4 (multisprite kernel)
          rem Players 3 & 4 have independent COLUP2/COLUP3 registers
          rem No color inheritance issues with proper multisprite
          rem   implementation
          
          rem Set Player 3 color and sprite (if active)
          
          if !(controllerStatus & SetQuadtariDetected) then goto DonePlayer3Sprite
          if playerCharacter[2] = NoCharacter then goto DonePlayer3Sprite
          if ! playerHealth[2] then goto DonePlayer3Sprite
          
          rem Use LoadCharacterColors for consistent color handling
          rem Player index
          let currentPlayer = 2
          rem Hurt flag (non-zero = recovering)
          let temp2 = playerRecoveryFrames[2]
          rem Guard flag (non-zero = guarding)
          let temp3 = playerState[2] & PlayerStateBitGuarding
          gosub LoadCharacterColors bank16
          COLUP2 = temp6
          rem fall through to Player3ColorDone
          
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

          let currentCharacter = playerCharacter[2]
          rem Load sprite data from character definition
          temp2 = 0
          rem Animation frame (0 = idle)
          temp3 = 0
          rem Animation action (0 = idle)
          gosub LoadCharacterSprite bank16
          
DonePlayer3Sprite

          rem Set Player 4 color and sprite (if active)

          if !(controllerStatus & SetQuadtariDetected) then goto DonePlayer4Sprite
          if playerCharacter[3] = NoCharacter then goto DonePlayer4Sprite
          if ! playerHealth[3] then goto DonePlayer4Sprite
          
          rem Use LoadCharacterColors for consistent color handling
          rem Player 4: Turquoise (player index color), hurt handled by
          rem Player index
          let currentPlayer = 3
          rem Hurt flag (non-zero = recovering)
          let temp2 = playerRecoveryFrames[3]
          rem Guard flag (non-zero = guarding)
          let temp3 = playerState[3] & PlayerStateBitGuarding
          gosub LoadCharacterColors bank16
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

          let currentCharacter = playerCharacter[3]
          rem Load sprite data from character definition
          temp2 = 0
          rem Animation frame (0 = idle)
          temp3 = 0
          rem Animation action (0 = idle)
          gosub LoadCharacterSprite bank16
          
DonePlayer4Sprite
          
          return

DisplayHealth
          rem
          rem Display Health
          rem Shows health status for all active players.
          rem Flashes sprites when health is critically low.
          rem Shows health status for all active players by flashing
          rem sprites when health is critically low
          rem
          rem Input: playerHealth[] (global array) = player health
          rem values, playerRecoveryFrames[] (global array) = recovery
          rem frame counts, controllerStatus (global) = controller
          rem state, playerCharacter[] (global array) = selections,
          rem frame (global) = frame counter
          rem
          rem Output: Sprites flashed (hidden) when health < 25 and not
          rem in recovery
          rem
          rem Mutates: player0x, player1x, player2x, player3x (TIA
          rem registers) = sprite positions (set to 200 to hide when
          rem flashing)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Only flashes when health < 25 and not in
          rem recovery. Players 3/4 only checked if Quadtari detected
          rem and selected
          rem Flash Participant 1 sprite (array [0], P0) if health is
          rem   low (but not during recovery)
          rem Use skip-over pattern to avoid complex || operator
          if playerHealth[0] >= 25 then goto DoneParticipant1Flash
          if playerRecoveryFrames[0] = 0 then FlashParticipant1
          goto DoneParticipant1Flash
FlashParticipant1
          if frame & 8 then player0x = 200 
DoneParticipant1Flash
          rem Hide P0 sprite

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
          if playerCharacter[2] = NoCharacter then goto DonePlayer3Flash
          if ! playerHealth[2] then goto DonePlayer3Flash
          if playerHealth[2] >= 25 then goto DonePlayer3Flash
          if playerRecoveryFrames[2] = 0 then FlashPlayer3
          goto DonePlayer3Flash
FlashPlayer3
          if frame & 8 then player2x = 200 
DonePlayer3Flash
          rem Player 3 uses player2 sprite

          rem Flash Player 4 sprite if health is low (but alive)

          if !(controllerStatus & SetQuadtariDetected) then goto DonePlayer4Flash
          if playerCharacter[3] = NoCharacter then goto DonePlayer4Flash
          if ! playerHealth[3] then goto DonePlayer4Flash
          if playerHealth[3] >= 25 then goto DonePlayer4Flash
          if playerRecoveryFrames[3] = 0 then FlashPlayer4
          goto DonePlayer4Flash
FlashPlayer4
          if frame & 8 then player3x = 200 
DonePlayer4Flash
          rem Player 4 uses player3 sprite
          
          return

