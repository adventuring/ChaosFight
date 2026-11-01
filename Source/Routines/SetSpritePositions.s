;;; ChaosFight - Source/Routines/SetSpritePositions.bas
;;; Copyright © 2025 Bruce-Robert Pocock.
;;; Assign p0/p1 hardware sprites to Players 1-4 with intelligent multiplexing
;;; P0=(Player 1, Player 3, or both); P1=(Player 2, Player 4, or both)
;;; Multiplex only when BOTH players in a pair are active
;;; Even frames: P0=Player 1 (if active) or Player 3; P1=Player 2 (if active) or Player 4
;;; Odd frames:  P0=Player 3 (if active) or Player 1; P1=Player 4 (if active) or Player 2
AssignP0P1Sprites:
           ;; Returns: Near (return thisbank)
           ;;
           ;; Input: controllerStatus, playerHealth[0-3], frame
           ;; Output: p0x/p0y, p1x/p1y set from playerX/playerY arrays
           ;; Mutates: temp1-temp3, p0x, p0y, p1x, p1y
           ;; Check if Player 3 or Player 4 are active (health > 0 and Quadtari)
           lda controllerStatus
           and # SetQuadtariDetected
           beq AssignP0P1_TwoPlayerOnly

           ;; Quadtari detected - check if Players 1&3 or 2&4 are both active for multiplexing
           ;; --- P0 assignment (Player 1 / Player 3) ---
           lda playerHealth+0   ; Player 1 health
           beq .P0_Player1Dead

           ;; Player 1 alive - check Player 3 health
           lda playerHealth+2   ; Player 3 health
           bne .P0_Multiplex   ; Player 3 also alive → multiplex p0

           ;; Player 1 alive, Player 3 dead → P0 = Player 1 always
           lda playerX
           sta p0x
           lda playerY
           sta p0y
           jmp .P0_Done

.P0_Player1Dead:
           ;; Player 1 dead - check Player 3 health
           lda playerHealth+2   ; Player 3 health
           beq .P0_BothDead

           ;; Player 1 dead, Player 3 alive → P0 = Player 3 always
           lda playerX+2
           sta p0x
           lda playerY+2
           sta p0y
           jmp .P0_Done

.P0_BothDead:
           ;; Both Player 1 and 3 dead - disable P0
           lda # 0
           sta p0x
           lda # 0
           sta p0y
           jmp .P0_Done

.P0_Multiplex:
           ;; Both Player 1 and Player 3 alive → multiplex based on frame parity
           lda frame
           and # 1
           bne .P0_OddFrame

.P0_EvenFrame:
           ;; Even frame: P0 = Player 1
           lda playerX
           sta p0x
           lda playerY
           sta p0y
           jmp .P0_Done

.P0_OddFrame:
           ;; Odd frame: P0 = Player 3
           lda playerX+2
           sta p0x
           lda playerY+2
           sta p0y

.P0_Done:
           ;; --- P1 assignment (Player 2 / Player 4) ---
           lda playerHealth+1   ; Player 2 health
           beq .P1_Player2Dead

           ;; Player 2 alive
           lda playerHealth+3   ; Player 4 health
           bne .P1_Multiplex   ; Player 4 also alive → multiplex p1

           ;; Player 2 alive, Player 4 dead → P1 = Player 2 always
           lda playerX+1
           sta p1x
           lda playerY+1
           sta p1y
           jmp .P1_Done

.P1_Player2Dead:
           ;; Player 2 dead - check Player 4 health
           lda playerHealth+3   ; Player 4 health
           beq .P1_BothDead

           ;; Player 2 dead, Player 4 alive → P1 = Player 4 always
           lda playerX+3
           sta p1x
           lda playerY+3
           sta p1y
           jmp .P1_Done

.P1_BothDead:
           ;; Both Player 2 and 4 dead - disable P1
           lda # 0
           sta p1x
           lda # 0
           sta p1y
           jmp .P1_Done

.P1_Multiplex:
           ;; Both Player 2 and Player 4 alive → multiplex based on frame parity
           lda frame
           and # 1
           bne .P1_OddFrame

.P1_EvenFrame:
           ;; Even frame: P1 = Player 2
           lda playerX+1
           sta p1x
           lda playerY+1
           sta p1y
           jmp .P1_Done

.P1_OddFrame:
           ;; Odd frame: P1 = Player 4
           lda playerX+3
           sta p1x
           lda playerY+3
           sta p1y

.P1_Done:
           rts

AssignP0P1_TwoPlayerOnly:
           ;; Only Players 1-2 active: no multiplexing needed
           ;; P0 = Player 1 (array [0])
           lda playerX
           sta p0x
           lda playerY
           sta p0y
           ;; P1 = Player 2 (array [1])
           lda playerX+1
           sta p1x
           lda playerY+1
           sta p1y
           rts

;;; Missile active mask lookup for participants 0-3
SetSpriteMissileMask:
              .byte 1, 2, 4, 8

CopyParticipantSpritePosition:
          ;; Returns: Near (return thisbank)
          ;; Copy participant position into multisprite hardware registers
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: temp1 = participant index (2 or 3, also equals sprite index)
          ;;
          ;; Output: player2/3 registers updated if participant is active
          ;;
          ;; Unified sprite position assignment (temp1 = 2 → player2, temp1 = 3 → player3)
          lda temp1
          tax
          lda playerX,x
          sta temp2
          lda playerY,x
          sta temp3
          lda temp1
          cmp # 2
          bne CPS_WritePlayer3

          lda temp2
          sta player2x
          lda temp3
          sta player2y
          rts

CPS_WritePlayer3:
          lda temp2
          sta player3x
          lda temp3
          sta player3y
          rts

SetSpritePositions:
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: temp1 = player index, temp2 = (document other inputs)
          ;;
          ;; Output: (document return values and state changes)
          ;;
          ;; Mutates: temp1-temp6 (as used), player position/velocity arrays
          ;;
          ;; Called Routines: (document subroutines called)
          ;;
          ;; Constraints: (document colocation/bank requirements)
          ;; Returns: Far (return otherbank)
          ;; Player Sprite Rendering
          ;; Returns: Far (return otherbank)
          ;; Handles sprite positioning, colors, and graphics for all
          ;; players.
          ;; SPRITE ASSIGNMENTS (MULTISPRITE KERNEL):
          ;; Player 1 (array [0]): p0 PMG sprite (p0x/p0y, COLUP0)
          ;; Player 2 (array [1]): p1 PMG sprite (p1x/p1y, NewCOLUP1 - virtual sprite)
          ;; Player 3 (array [2]): P2 sprite (player2x/player2y, colup2)
          ;; Player 4 (array [3]): P3 sprite (player3x/player3y, colup3)
          ;; MISSILE SPRITES:
          ;; 2-player mode: missile0 = Player 1, missile1 = Player 2 (no multiplexing)
          ;; 4-player mode: missile0/missile1 multiplexed between all 4 players (even/odd frames)
          ;; AVAILABLE VARIABLES:
          ;; playerX[0-3], playerY[0-3] - Positions
          ;; playerState[0-3] - State flags
          ;; playerRecoveryFrames[0-3] - Hitstun frames
          ;; missileActive (bit flags) - Projectile states (bit 0=P0,
          ;; bit 1=P1, bit 2=P2, bit 3=P3)
          ;; missileX[0-3], missileY[0-3] - Projectile positions
          ;; controllerStatus flags (SetQuadtariDetected, SetPlayers34Active)
          ;; Set Sprite Positions
          ;; Update hardware sprite position registers for all active players and missiles.
          ;;
          ;; Input: playerX[], playerY[] (global arrays) = player
          ;; positions, missileX[] (global array) = missile X
          ;; positions, missileY_R[] (global SCRAM array) = missile Y
          ;; positions, missileActive (global) = missile active flags,
          ;; playerCharacter[] (global array) = character types,
          ;; controllerStatus (global) = controller sta
          ;; playerHealth[] (global array) = player
          ;; health, frame (global) = frame counter, missileNUSIZ[]
          ;; (global array) = missile size registers,
          ;; CharacterMissileHeights[] (global data table) = missile
          ;; heights, characterStateFlags_R[] (global SCRAM array) =
          ;; character state flags, playerState[] (global array) =
          ;; player states, missileStretchHeight_R[] (global SCRAM
          ;; array) = stretch missile heights
          ;;
          ;; Output: All sprite positions set, missile positions set
          ;; with frame multiplexing in 4-player mode
          ;;
          ;; Mutates: player0x, player0y, player1x, player1y, player2x,
          ;; player2y, player3x, player3y (TIA registers) = sprite
          ;; positions, missile0x, missile0y, missile1x, missile1y (TIA
          ;; registers) = missile positions, ENAM0, ENAM1 (TIA
          ;; registers) = missile enable flags, missile0height,
          ;; missile1height (TIA registers) = missile heights, NUSIZ0,
          ;; NUSIZ1 (TIA registers) = missile size registers,
          ;; temp1-temp6 (used for calculations)
          ;;
          ;; Called Routines: RenderRoboTitoStretchMissile - renders RoboTito
          ;; stretch missiles when no projectile is active
          ;;
          ;; Constraints: 4-player mode uses frame multiplexing (even
          ;; frames = P1/P2, odd frames = P3/P4)
          ;; Set player sprite positions
          ;; player0x = (values set via CopyParticipantSpritePosition)
          ;; player0y = (values set via CopyParticipantSpritePosition)
          ;; player1x = (values set via CopyParticipantSpritePosition)
          ;; player1y = (values set via CopyParticipantSpritePosition)
          ;; Assign p0 (PMG) and p1 (PMG) to active Players 1-4
          ;; Multiplex only when Player 3 or 4 are active; otherwise p0=Player 1, p1=Player 2
          jsr AssignP0P1Sprites

          ;; Set positions for participants 3 & 4 in 4-player mode
          ;; (multisprite kernel)
          ;; Participant 3 (array [2]): P2 sprite (player2x/player2y,
          ;; colup2)
          ;; Participant 4 (array [3]): P3 sprite (player3x/player3y,
          ;; colup3)
          ;; Missiles are available for projectiles since participants
          ;; use proper sprites
          ;; Set Participant 3 & 4 positions (arrays [2] & [3] → P2 & P3 sprites)
          ;; Issue #1254: Loop through temp1 = 2 to 3
          lda # 2
          sta temp1
SSP_ParticipantLoop:
          jsr CopyParticipantSpritePosition

          ;; Issue #1254: Loop increment and check
          inc temp1
          lda temp1
          cmp # 4
          bcs SSP_ParticipantLoopDone

          jmp SSP_ParticipantLoop

SSP_ParticipantLoopDone:


          ;; Set missile positions for projectiles
          ;; Hardware missiles: missile0 and missile1 (only 2 physical
          ;; missiles available on TIA)
          ;; In 2-player mode: missile0 = Player 1, missile1 = Player 2 (no multiplexing needed)
          ;; In 4-player mode: missile0/missile1 multiplexed between all 4 Players (even/odd frames)
          ;; Even frames: missile0 = Participant 1 (array [0]), missile1 = Participant 2 (array [1])
          ;; Odd frames: missile0 = Participant 3 (array [2]), missile1 = Participant 4 (array [3])
          ;; Use missileActive bit flags: bit 0 = Participant 1, bit 1
          ;; = Participant 2, bit 2 = Participant 3, bit 3 =
          ;; Participant 4
          ;; Check if participants 3 or 4 are active (selected and not
          ;; eliminated)
          ;; Use this flag instead of QuadtariDetected for missile
          ;; multiplexing
          ;; because we only need to multiplex when participants 3 or 4
          ;; are actually in the game
          lda # 0
          sta ENAM0
          lda # 0
          sta ENAM1
          lda # 0
          sta missile0height
          lda # 0
          sta missile1height
          jsr SetSpritePositionsRenderMissiles

          jmp BS_return

SetSpritePositionsRenderMissiles:
          ;; Returns: Near (return thisbank)
          lda controllerStatus
          and # SetPlayers34Active
          bne SSP_CheckTwoPlayer

          jmp RenderMissilesTwoPlayer

SSP_CheckTwoPlayer:
          ;; Set temp6 = frame & 1
          lda frame
          and # 1
          sta temp6

          lda frame
          and # 1
          sta temp6

          ;; if temp6 then jmp RenderMissilesOddFrame

          lda temp6
          beq SSP_CheckEvenFrame

          jmp RenderMissilesOddFrame

SSP_CheckEvenFrame:

          lda # 0
          sta temp1
          jmp RenderMissilePair

RenderMissilesOddFrame:
          lda # 2
          sta temp1
          jmp RenderMissilePair

RenderMissilesTwoPlayer:
          lda # 0
          sta temp1

RenderMissilePair:
          jsr SetSpritePositionsRenderPair

          rts

SetSpritePositionsRenderPair:
          ;; Returns: Near (return thisbank)
          jsr RenderMissileForParticipant

          inc temp1
          jsr RenderMissileForParticipant

          rts

RenderMissileForParticipant:
          ;; Returns: Near (return thisbank)
          ;; Render projectile or RoboTito stretch missile for a participant
          ;; Returns: Near (return thisbank)
          ;;
          ;; Input: temp1 = participant index (0-3)
          ;;
          ;; Output: missile registers updated for the selected participant
          ;;
          ;; Mutates: temp1-temp5 (used for calculations), missile registers
          ;;
          ;; RMF_participant = temp1 (input parameter)
          ;; RMF_select = temp2 (calculated)
          ;; RMF_mask = temp3 (calculated)
          ;; RMF_character = temp4 (calculated)
          ;; RMF_active = temp5 (calculated)
          ;; Set RMF_select = RMF_participant & 1
          lda temp1
          and # 1
          sta temp2

          ;; Set RMF_mask = SetSpriteMissileMask[RMF_participant]
          lda temp1
          tax
          lda SetSpriteMissileMask,x
          sta temp3
          lda missileActive
          and temp3
          sta temp5
          ;; if RMF_active then jmp RMF_MissileActive

          lda temp5
          beq RMF_CheckMissileActive

          jmp RMF_MissileActive

RMF_CheckMissileActive:
          lda temp2
          sta temp2
          ;; Cross-bank call to RenderRoboTitoStretchMissile in bank 7
          ;; Return address: ENCODED with caller bank 5 ($50) for BS_return to decode
          lda # ((>(RMF_ReturnPoint-1)) & $0f) | $50  ;;; Encode bank 5 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: RMF_ReturnPoint hi (encoded)]
          lda # <(RMF_ReturnPoint-1)
          pha
          ;; STACK PICTURE: [SP+1: RMF_ReturnPoint hi (encoded)] [SP+0: RMF_ReturnPoint lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(RenderRoboTitoStretchMissile-1)
          pha
          ;; STACK PICTURE: [SP+2: RMF_ReturnPoint hi (encoded)] [SP+1: RMF_ReturnPoint lo] [SP+0: RenderRoboTitoStretchMissile hi (raw)]
          lda # <(RenderRoboTitoStretchMissile-1)
          pha
          ;; STACK PICTURE: [SP+3: RMF_ReturnPoint hi (encoded)] [SP+2: RMF_ReturnPoint lo] [SP+1: RenderRoboTitoStretchMissile hi (raw)] [SP+0: RenderRoboTitoStretchMissile lo]
          ldx # 7
          jmp BS_jsr

RMF_ReturnPoint:

          jmp BS_return

RMF_MissileActive .proc
          ;; Returns: Far (return otherbank)
          ;; Set RMF_character = playerCharacter[RMF_participant]
          lda temp1
          tax
          lda playerCharacter,x
          sta temp4
          lda temp2
          sta temp5
          jsr SSP_WriteMissileRegisters

          jmp BS_return

.pend

SSP_WriteMissileRegisters .proc
          ;; Write missile registers for selected hardware slot
          ;; Returns: Near (return thisbank)
          ;; Input: temp5 = missile select (0=missile0, 1=missile1), temp1 = participant index, temp4 = character
          ;; Use unified helper to write missile registers
          ;; Save values to temp variables for unified helper (temp2-temp4 already used by caller, use temp6)
          ;; temp2 = Y position
          ;; Set temp6 = missileX[temp1]
          lda temp1
          tax
          lda missileX,x
          sta temp6
          ;; temp3 = NUSIZ value
          ;; Set temp2 = missileY_R[temp1]
          lda temp1
          tax
          lda missileY_R,x
          sta temp2
          ;; temp4 = height (overwrite character after reading it)
          ;; Set temp3 = missileNUSIZ_R[temp1]
          lda temp1
          tax
          lda missileNUSIZ_R,x
          sta temp3
          ;; Set temp4 = CharacterMissileHeights[temp4]
          lda temp4
          tax
          lda CharacterMissileHeights,x
          sta temp4
          jsr SSP_WriteMissileRegistersUnified

          rts

.pend

SSP_WriteMissileRegistersUnified .proc
          ;; Returns: Near (return thisbank)
          ;; Unified helper to write missile registers for either missile0 or missile1
          ;; Returns: Near (return thisbank)
          ;; Input: temp5 = missile select (0=missile0, 1=missile1)
          ;; temp6 = X position, temp2 = Y position, temp3 = NUSIZ, temp4 = height
          lda temp5
          bne SSP_CheckMissile0

          jmp SSP_WriteUnified0

SSP_CheckMissile0:


          lda temp6
          sta missile1x
          lda temp2
          sta missile1y
          lda # 1
          sta ENAM1
          lda temp3
          sta NUSIZ1
          lda temp4
          sta missile1height
          rts

SSP_WriteUnified0:
          lda temp6
          sta missile0x
          lda temp2
          sta missile0y
          lda # 1
          sta ENAM0
          lda temp3
          sta NUSIZ0
          lda temp4
          sta missile0height
          rts

.pend

RenderRoboTitoStretchMissile .proc
          ;; Returns: Far (return otherbank)
          ;; Render RoboTito stretch visual missiles for whichever hardware slot
          ;; Returns: Far (return otherbank)
          ;; is currently multiplexed to the participant.
          ;;
          ;; Input: temp1 = participant index (0-3)
          ;; temp2 = hardware missile select (0 = missile0, 1 = missile1)
          ;;
          ;; Output: Selected missile rendered as stretch visual if player is
          ;; RoboTito, stretching upward, and stretch height > 0
          ;;
          ;; Mutates: temp1-temp4 (used for calculations), missile registers
          ;;
          ;; Constraints: Caller supplies participant/missile pairing so this
          ;; routine does not perform frame-parity dispatch.
          ;; If playerCharacter[temp1] = CharacterRoboTito, then RRTM_CheckStretch
          lda temp1
          tax
          lda playerCharacter,x
          cmp # CharacterRoboTito
          bne RRTM_CheckStretchDone

          jmp RRTM_CheckStretch

RRTM_CheckStretchDone:
          jmp BS_return

.pend

RRTM_CheckStretch .proc
          ;; Returns: Far (return otherbank)
          jmp BS_return

          ;; Set temp3 = playerState[temp1]
          lda temp1
          tax
          lda playerState,x
          sta temp3
          ;; Set temp3 = temp3 & 240
          lda temp3
          and # 240
          sta temp3

          lda temp3
          and # 240
          sta temp3

          ;; Set temp3 = temp3 / 16
          lda temp3
          cmp # 10
          bne RRTM_CheckStretchActive

          jsr RRTM_ReadStretchHeight

RRTM_CheckStretchActive:

          jmp BS_return

.pend

RRTM_ReadStretchHeight .proc
           ;; Set temp4 = missileStretchHeight_R[temp1]
           lda temp1
           tax
           lda missileStretchHeight_R,x
           sta temp4
           jmp BS_return

.pend

SSP_WriteStretchMissile .proc
          ;; Write stretch missile registers for selected hardware slot
          ;; Returns: Near (return thisbank)
          ;; Input: temp5 = missile select (0=missile0, 1=missile1), temp1 = participant, temp4 = height
          ;; Use unified helper with stretch-specific parameters (NUSIZ=0, position from player)
                    ;; Set temp6 = playerX[temp1]
                    lda temp1          asl          tax          lda playerX,x          sta temp6
          ;; Set temp2 = playerY[temp1]
          lda temp1
          tax
          lda playerY,x
          sta temp2
          lda temp1
          tax
          lda playerY,x
          sta temp2
          ;; temp4 already set to height
          lda # 0
          sta temp3
          jsr SSP_WriteMissileRegistersUnified

          rts

.pend

