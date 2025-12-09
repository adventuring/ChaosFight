;;; ChaosFight - Source/Routines/ProcessUpAction.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

ProcessUpAction
;; ProcessUpAction (duplicate)
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
          ;; TODO: Implement Shamone <-> MethHound form switching

          ;; Robo Tito: Stretch (ascend toward ceiling; auto-latch on contact)
                    ;; if playerCharacter[temp1] = CharacterRoboTito then goto PUA_RoboTitoAscend

          ;; Bernie: Drop (fall through thin floors)
                    ;; if playerCharacter[temp1] = CharacterBernie then goto PUA_BernieFallThrough
          lda temp1
          asl
          tax
          ;; lda playerCharacter,x (duplicate)
          cmp CharacterBernie
          bne skip_7306
          jmp PUA_BernieFallThrough
skip_7306:

          ;; Harpy: Flap (fly)
                    ;; if playerCharacter[temp1] = CharacterHarpy then goto PUA_HarpyFlap
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; cmp CharacterHarpy (duplicate)
          ;; bne skip_2587 (duplicate)
          ;; jmp PUA_HarpyFlap (duplicate)
skip_2587:

          ;; For all other characters, UP is jump
          ;; Check Zoe Ryen for double-jump capability
                    ;; if playerCharacter[temp1] = CharacterZoeRyen then goto PUA_ZoeJumpCheck
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; cmp CharacterZoeRyen (duplicate)
          ;; bne skip_8150 (duplicate)
          ;; jmp PUA_ZoeJumpCheck (duplicate)
skip_8150:

          ;; Standard jump - block during attack animations (states 13-15)
          ;; Tail call to DispatchCharacterJump - it returns directly to our caller
                    ;; let temp4 = playerCharacter[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          sta temp4
          jmp DispatchCharacterJump


PUA_BernieFallThrough .proc
          ;; Bernie UP handled in BernieJump routine (fall through 1-row floors)
          ;; CRITICAL: Must use gosub/return, not goto, because BernieJump returns otherbank
          ;; lda # 0 (duplicate)
          ;; sta temp3 (duplicate)
          ;; Cross-bank call to BernieJump in bank 12
          ;; lda # >(return_point-1) (duplicate)
          pha
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(BernieJump-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(BernieJump-1) (duplicate)
          ;; pha (duplicate)
                    ldx # 11
          ;; jmp BS_jsr (duplicate)
return_point:

          ;; rts (duplicate)

.pend

PUA_HarpyFlap .proc
          ;; Harpy UP handled in HarpyJump routine (flap to fly)
          ;; CRITICAL: Must use gosub/return, not goto, because HarpyJump returns otherbank
          ;; lda # 0 (duplicate)
          ;; sta temp3 (duplicate)
          ;; Cross-bank call to HarpyJump in bank 12
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(HarpyJump-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(HarpyJump-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 11 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)

          ;; rts (duplicate)

PUA_RoboTitoAscend
          ;; Ascend toward ceiling
                    ;; let temp6 = playerCharacter[temp1]          lda temp1          asl          tax          lda playerCharacter,x          sta temp6
                    ;; let temp6 = CharacterMovementSpeed[temp6]
          ;; lda temp6 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMovementSpeed,x (duplicate)
          ;; sta temp6 (duplicate)
          ;; lda temp6 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMovementSpeed,x (duplicate)
          ;; sta temp6 (duplicate)
          ;; Compute playfield column
                    ;; let playerY[temp1] = playerY[temp1] - temp6
                    ;; let temp2 = playerX[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerX,x (duplicate)
          ;; sta temp2 (duplicate)
          ;; ;; let temp2 = temp2 - ScreenInsetX          lda temp2          sec          sbc ScreenInsetX          sta temp2
          ;; lda temp2 (duplicate)
          sec
          sbc ScreenInsetX
          ;; sta temp2 (duplicate)

          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc ScreenInsetX (duplicate)
          ;; sta temp2 (duplicate)

            lsr temp2
            ;; lsr temp2 (duplicate)
          ;; lda temp2 (duplicate)
          ;; cmp # 32 (duplicate)
          bcc skip_9153
          ;; lda # 31 (duplicate)
          ;; sta temp2 (duplicate)
skip_9153:

                    ;; if temp2 & $80 then let temp2 = 0
          ;; Save playfield column (temp2 will be overwritten)
          ;; lda temp2 (duplicate)
          ;; sta temp4 (duplicate)
          ;; Compute head row and check ceiling contact
                    ;; let temp2 = playerY[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; sta temp2 (duplicate)
            ;; lsr temp2 (duplicate)
            ;; lsr temp2 (duplicate)
            ;; lsr temp2 (duplicate)
            ;; lsr temp2 (duplicate)
          ;; lda temp2 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_4246 (duplicate)
          ;; jmp PUA_RoboTitoLatch (duplicate)
skip_4246:

          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc # 1 (duplicate)
          ;; sta temp3 (duplicate)
          ;; lda temp1 (duplicate)
          ;; sta currentPlayer (duplicate)
          ;; lda temp4 (duplicate)
          ;; sta temp1 (duplicate)
          ;; lda temp3 (duplicate)
          ;; sta temp2 (duplicate)
          ;; Cross-bank call to PlayfieldRead in bank 16
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 15 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)

                    ;; if temp1 then goto PUA_RoboTitoLatch
          ;; lda temp1 (duplicate)
          beq skip_6148
          ;; jmp PUA_RoboTitoLatch (duplicate)
skip_6148:
          ;; Clear latch if DOWN pressed (check appropriate port)
          ;; lda currentPlayer (duplicate)
          ;; sta temp1 (duplicate)
                    ;; if temp1 & 2 = 0 then goto PUA_CheckJoy0Down
                    ;; if joy1down then let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] & (255 - 1)
          ;; lda joy1down (duplicate)
          ;; beq skip_7336 (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda characterStateFlags_R,x (duplicate)
          and # 254
          ;; sta characterStateFlags_W,x (duplicate)
skip_7336:
          ;; lda # 0 (duplicate)
          ;; sta temp3 (duplicate)
          ;; rts (duplicate)
.pend

PUA_CheckJoy0Down .proc
                    ;; if joy0down then let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] & (255 - 1)          lda joy0down          beq skip_9849
skip_9849:
          ;; jmp skip_9849 (duplicate)
          ;; lda # 0 (duplicate)
          ;; sta temp3 (duplicate)
          ;; rts (duplicate)
.pend

PUA_RoboTitoLatch .proc
                    ;; let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] | 1
          ;; lda # 0 (duplicate)
          ;; sta temp3 (duplicate)
          ;; rts (duplicate)

.pend

PUA_ZoeJumpCheck .proc
          ;; Zoe Ryen: Allow single mid-air double-jump
          ;; lda # 0 (duplicate)
          ;; sta temp6 (duplicate)
                    ;; if (playerState[temp1] & 4) then let temp6 = 1
          ;; Block double-jump if already used (characterStateFlags bit 3)
          ;; rts (duplicate)
          ;; Block jump during attack animations (states 13-15)
          ;; rts (duplicate)
                    ;; let temp4 = playerCharacter[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta temp4 (duplicate)
          ;; jsr DispatchCharacterJump (duplicate)
          ;; Set double-jump flag if jumping in air
          ;; lda temp6 (duplicate)
          ;; cmp # 1 (duplicate)
          ;; bne skip_6415 (duplicate)
                    ;; let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] | 8
skip_6415:

          ;; lda # 1 (duplicate)
          ;; sta temp3 (duplicate)
          ;; rts (duplicate)


.pend

