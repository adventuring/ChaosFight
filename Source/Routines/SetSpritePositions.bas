          rem ChaosFight - Source/Routines/SetSpritePositions.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

          rem Missile active mask lookup for participants 0-3
          data SetSpriteMissileMask
            1, 2, 4, 8
end

SetSpritePositions
          rem Returns: Far (return otherbank)
          asm
SetSpritePositions
end

          rem Player Sprite Rendering
          rem Returns: Far (return otherbank)
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
          rem Called Routines: RenderRoboTitoStretchMissile - renders RoboTito
          rem stretch missiles when no projectile is active
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
          rem Set Participant 3 & 4 positions (arrays [2] & [3] → P2 & P3 sprites)
          rem Loop over participants 2-3 instead of duplicate calls
          for temp1 = 2 to 3
            gosub CopyParticipantSpritePosition
          next

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
          ENAM0 = 0
          ENAM1 = 0
          missile0height = 0
          missile1height = 0
          gosub SetSpritePositionsRenderMissiles
          return otherbank

SetSpritePositionsRenderMissiles
          rem Returns: Far (return thisbank)
          asm
SetSpritePositionsRenderMissiles
end
          if (controllerStatus & SetPlayers34Active) = 0 then goto RenderMissilesTwoPlayer
          let temp6 = frame & 1
          if temp6 then goto RenderMissilesOddFrame
          let temp1 = 0
          goto RenderMissilePair
RenderMissilesOddFrame
          let temp1 = 2
          goto RenderMissilePair
RenderMissilesTwoPlayer
          let temp1 = 0
RenderMissilePair
          gosub SetSpritePositionsRenderPair
          return thisbank
SetSpritePositionsRenderPair
          rem Returns: Far (return thisbank)
          asm
SetSpritePositionsRenderPair
end
          gosub RenderMissileForParticipant
          let temp1 = temp1 + 1
          gosub RenderMissileForParticipant
          return otherbank

RenderMissileForParticipant
          rem Returns: Far (return thisbank)
          asm
RenderMissileForParticipant
end
          rem Render projectile or RoboTito stretch missile for a participant
          rem Returns: Far (return otherbank)
          rem
          rem Input: temp1 = participant index (0-3)
          rem
          rem Output: missile registers updated for the selected participant
          rem
          rem Mutates: temp1-temp5 (used for calculations), missile registers
          rem
          dim RMF_participant = temp1
          dim RMF_select = temp2
          dim RMF_mask = temp3
          dim RMF_character = temp4
          dim RMF_active = temp5
          let RMF_select = RMF_participant & 1
          let RMF_mask = SetSpriteMissileMask[RMF_participant]
          let RMF_active = missileActive & RMF_mask
          if RMF_active then goto RMF_MissileActive
          let temp2 = RMF_select
          gosub RenderRoboTitoStretchMissile bank8
          return otherbank

RMF_MissileActive
          rem Returns: Far (return otherbank)
          let RMF_character = playerCharacter[RMF_participant]
          let temp5 = RMF_select
          gosub SSP_WriteMissileRegisters
          return otherbank
SSP_WriteMissileRegisters
          rem Returns: Far (return thisbank)
          asm
SSP_WriteMissileRegisters
end
          rem Write missile registers for selected hardware slot
          rem Returns: Far (return otherbank)
          rem Input: temp5 = missile select (0=missile0, 1=missile1), RMF_participant, RMF_character
          rem Use unified helper to write missile registers
          rem Save values to temp variables for unified helper (temp2-temp4 already used by caller, use temp6)
          rem temp2 = Y position
          let temp6 = missileX[RMF_participant]
          rem temp3 = NUSIZ value
          let temp2 = missileY_R[RMF_participant]
          rem temp4 = height (overwrite RMF_character after reading it)
          let temp3 = missileNUSIZ_R[RMF_participant]
          let temp4 = CharacterMissileHeights[RMF_character]
          gosub SSP_WriteMissileRegistersUnified
          return otherbank
SSP_WriteMissileRegistersUnified
          rem Returns: Far (return thisbank)
          asm
SSP_WriteMissileRegistersUnified
end
          rem Unified helper to write missile registers for either missile0 or missile1
          rem Returns: Far (return otherbank)
          rem Input: temp5 = missile select (0=missile0, 1=missile1)
          rem        temp6 = X position, temp2 = Y position, temp3 = NUSIZ, temp4 = height
          if temp5 = 0 then goto SSP_WriteUnified0
          missile1x = temp6
          missile1y = temp2
          ENAM1 = 1
          NUSIZ1 = temp3
          missile1height = temp4
          return otherbank
SSP_WriteUnified0
          missile0x = temp6
          missile0y = temp2
          ENAM0 = 1
          NUSIZ0 = temp3
          missile0height = temp4
          return thisbank
CopyParticipantSpritePosition
          rem Returns: Far (return thisbank)
          asm
CopyParticipantSpritePosition
end
          rem Copy participant position into multisprite hardware registers
          rem Returns: Far (return otherbank)
          rem
          rem Input: temp1 = participant index (2 or 3, also equals sprite index)
          rem
          rem Output: player2/3 registers updated if participant is active
          rem
          if (controllerStatus & SetQuadtariDetected) = 0 then return otherbank
          if playerCharacter[temp1] = NoCharacter then return otherbank
          rem Unified sprite position assignment (temp1 = 2 → player2, temp1 = 3 → player3)
          if ! playerHealth[temp1] then return otherbank
          if temp1 = 2 then goto CPS_WritePlayer2
          player3x = playerX[temp1]
          player3y = playerY[temp1]
          return otherbank

CPS_WritePlayer2
          rem Returns: Far (return otherbank)
          player2x = playerX[temp1]
          player2y = playerY[temp1]
          return otherbank
RenderRoboTitoStretchMissile
          rem Returns: Far (return otherbank)
          asm
RenderRoboTitoStretchMissile

end
          rem Render RoboTito stretch visual missiles for whichever hardware slot
          rem Returns: Far (return otherbank)
          rem is currently multiplexed to the participant.
          rem
          rem Input: temp1 = participant index (0-3)
          rem        temp2 = hardware missile select (0 = missile0, 1 = missile1)
          rem
          rem Output: Selected missile rendered as stretch visual if player is
          rem         RoboTito, stretching upward, and stretch height > 0
          rem
          rem Mutates: temp1-temp4 (used for calculations), missile registers
          rem
          rem Constraints: Caller supplies participant/missile pairing so this
          rem               routine does not perform frame-parity dispatch.
          if playerCharacter[temp1] = CharacterRoboTito then RRTM_CheckStretch
          return otherbank

RRTM_CheckStretch
          rem Returns: Far (return otherbank)
          if (characterStateFlags_R[temp1] & 1) then return otherbank
          let temp3 = playerState[temp1]
          let temp3 = temp3 & 240
          let temp3 = temp3 / 16
          if temp3 = 10 then RRTM_ReadStretchHeight
          return otherbank
RRTM_ReadStretchHeight
          let temp4 = missileStretchHeight_R[temp1]
          if temp4 <= 0 then return otherbank
          let temp5 = temp2
          gosub SSP_WriteStretchMissile
          return otherbank
SSP_WriteStretchMissile
          rem Returns: Far (return thisbank)
          asm
SSP_WriteStretchMissile
end
          rem Write stretch missile registers for selected hardware slot
          rem Returns: Far (return otherbank)
          rem Input: temp5 = missile select (0=missile0, 1=missile1), temp1 = participant, temp4 = height
          rem Use unified helper with stretch-specific parameters (NUSIZ=0, position from player)
          let temp6 = playerX[temp1]
          let temp2 = playerY[temp1]
          rem temp4 already set to height
          let temp3 = 0
          gosub SSP_WriteMissileRegistersUnified
          return otherbank
