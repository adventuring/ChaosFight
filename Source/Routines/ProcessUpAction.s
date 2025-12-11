;;; ChaosFight - Source/Routines/ProcessUpAction.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

ProcessUpAction:
          ;; Shared UP Action Handler
          ;; Executes character-specific UP behavior (UP = Button C = Button II, no exceptions)
          ;;
          ;; Character-specific UP actions:
          ;; Shamone/MethHound: Body change (form switch)
          ;; RoboTito: Stretch (ascend toward ceiling)
          ;; Bernie: Drop (fall through thin floors)
          ;; Harpy: Flap (fly)
          ;; Dragon of Storms: Move up
          ;; Frooty (Fairy): Accelerate up
          ;; Most other characters: Jump
          ;;
          ;; INPUT: temp1 = player index (0-3)
          ;; temp2 = cached animation state (for attack blocking)
          ;;
          ;; OUTPUT: temp3 = 1 if action was jump, 0 if special ability
          ;;
          ;; Mutates: temp2, temp3, temp4, temp6, playerCharacter[],
          ;; playerY[], characterStateFlags_W[]
          ;;
          ;; Called Routines: BernieJump (bank12), HarpyJump (bank12),
          ;; DispatchCharacterJump (bank8), PlayfieldRead (bank16)
          ;;
          ;; Constraints: Must be colocated with helpers in same bank

          ;; Check Shamone form switching first (Shamone <-> MethHound)
          ;; TODO: #1249 Implement Shamone <-> MethHound form switching

          ;; Robo Tito: Stretch (ascend toward ceiling; auto-latch on contact)
          ;; if playerCharacter[temp1] = CharacterRoboTito then goto RoboTitoAscendUpAction

          ;; Bernie: Drop (fall through thin floors)
          ;; if playerCharacter[temp1] = CharacterBernie then goto BernieFallThroughUpAction
          lda temp1
          asl
          tax
          lda playerCharacter,x
          cmp # CharacterBernie
          bne CheckHarpy

          jmp BernieFallThroughUpAction

CheckHarpy:

          ;; Harpy: Flap (fly)
          ;; if playerCharacter[temp1] = CharacterHarpy then goto HarpyFlapUpAction
          lda temp1
          asl
          tax
          lda playerCharacter,x
          cmp # CharacterHarpy
          bne CheckZoeRyen

          jmp HarpyFlapUpAction

CheckZoeRyen:

          ;; For all other characters, UP is jump
          ;; Check Zoe Ryen for double-jump capability
          ;; if playerCharacter[temp1] = CharacterZoeRyen then goto ZoeJumpCheckUpAction
          lda temp1
          asl
          tax
          lda playerCharacter,x
          cmp # CharacterZoeRyen
          bne StandardJump

          jmp ZoeJumpCheckUpAction

StandardJump:

          ;; Standard jump - block during attack animations (states 13-15)
          ;; Tail call to DispatchCharacterJump - it returns directly to our caller
          ;; let temp4 = playerCharacter[temp1]         
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp4
          jmp DispatchCharacterJump

BernieFallThroughUpAction .proc
          ;; Bernie UP handled in BernieJump routine (fall through 1-row floors)
          ;; CRITICAL: Must use gosub/return, not goto, because BernieJump returns otherbank
          lda # 0
          sta temp3
          ;; Cross-bank call to BernieJump in bank 12
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(BernieJump-1)
          pha
          lda # <(BernieJump-1)
          pha
          ldx # 11
          jmp BS_jsr

AfterBernieJump:

          rts

.pend

HarpyFlapUpAction .proc
          ;; Harpy UP handled in HarpyJump routine (flap to fly)
          ;; CRITICAL: Must use gosub/return, not goto, because HarpyJump returns otherbank
          lda # 0
          sta temp3
          ;; Cross-bank call to HarpyJump in bank 12
          lda # >(AfterHarpyJump-1)
          pha
          lda # <(AfterHarpyJump-1)
          pha
          lda # >(HarpyJump-1)
          pha
          lda # <(HarpyJump-1)
          pha
          ldx # 11
          jmp BS_jsr

AfterHarpyJump:

          rts
.pend

RoboTitoAscendUpAction:
          ;; Ascend toward ceiling
          ;; let temp6 = playerCharacter[temp1]
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp6
          ;; let temp6 = CharacterMovementSpeed[temp6]
          lda temp6
          asl
          tax
          lda CharacterMovementSpeed,x
          sta temp6
          lda temp6
          asl
          tax
          lda CharacterMovementSpeed,x
          sta temp6
          ;; Compute playfield column
          ;; let playerY[temp1] = playerY[temp1] - temp6
          ;; let temp2 = playerX[temp1]         
          lda temp1
          asl
          tax
          lda playerX,x
          sta temp2
          ;; let temp2 = temp2 - ScreenInsetX
          lda temp2
          sec
          sbc # ScreenInsetX
          sta temp2

          lda temp2
          sec
          sbc # ScreenInsetX
          sta temp2

            lsr temp2
            lsr temp2
          lda temp2
          cmp # 32
          bcc ColumnInRange

          lda # 31
          sta temp2

ColumnInRange:

          ;; if temp2 & $80 then let temp2 = 0
          ;; Save playfield column (temp2 will be overwritten)
          lda temp2
          sta temp4
          ;; Compute head row and check ceiling contact
          ;; let temp2 = playerY[temp1]         
          lda temp1
          asl
          tax
          lda playerY,x
          sta temp2
            lsr temp2
            lsr temp2
            lsr temp2
            lsr temp2
          lda temp2
          cmp # 0
          bne CheckCeilingPixel

          jmp RoboTitoLatchUpAction

CheckCeilingPixel:

          lda temp2
          sec
          sbc # 1
          sta temp3
          lda temp1
          sta currentPlayer
          lda temp4
          sta temp1
          lda temp3
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

AfterPlayfieldReadRoboTitoAscend:

          ;; if temp1 then goto RoboTitoLatchUpAction
          lda temp1
          beq CheckDownPressed

          jmp RoboTitoLatchUpAction

CheckDownPressed:
          ;; Clear latch if DOWN pressed (check appropriate port)
          lda currentPlayer
          sta temp1
          ;; if temp1 & 2 = 0 then goto CheckJoy0DownUpAction
          ;; if joy1down then let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] & (255 - 1)
          ;; lda joy1down (undefined - commented out)
          beq ProcessUpActionDone

          lda temp1
          asl
          tax
          lda characterStateFlags_R,x
          and # 254
          sta characterStateFlags_W,x

ProcessUpActionDone:
          lda # 0
          sta temp3
          rts

CheckJoy0DownUpAction .proc
          ;; if joy0down then let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] & (255 - 1)
          lda joy0down
          beq ProcessUpActionDoneLabel

ProcessUpActionDoneLabel:
          jmp ProcessUpActionDoneLabel

          lda # 0
          sta temp3
          rts

.pend

PUA_RoboTitoLatch .proc
          ;; let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] | 1
          lda # 0
          sta temp3
          rts

.pend

ZoeJumpCheckUpAction .proc
          ;; Zoe Ryen: Allow single mid-air double-jump
          lda # 0
          sta temp6
          ;; if (playerState[temp1] & 4) then let temp6 = 1
          ;; Block double-jump if already used (characterStateFlags bit 3)
          rts

          ;; Block jump during attack animations (states 13-15)
          rts

          ;; let temp4 = playerCharacter[temp1]         
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp4
          jsr DispatchCharacterJump

          ;; Set double-jump flag if jumping in air
          lda temp6
          cmp # 1
          bne SetJumpFlag

          ;; let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] | 8

SetJumpFlag:

          lda # 1
          sta temp3
          rts

.pend

