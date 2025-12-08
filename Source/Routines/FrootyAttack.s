;;; ChaosFight - Source/Routines/FrootyAttack.bas

;;; Copyright © 2025 Bruce-Robert Pocock.

;;; Issue #1177: Frooty lollipop charge-and-bounce attack




FrootyAttack .proc


          ;; Issue #1177: Frooty lollipop charge-and-bounce attack
          ;; Returns: Far (return otherbank)

          ;; Charge meter advances at 10 Hz (every 0.1s) while action button is held

          ;; Maximum charge duration approximately 3 seconds (30 ticks)

          ;; On button release, spawn and launch the lollipop projectile

          ;; Projectile ricochets off arena bounds like a Breakout/Pong ball

          ;; Bounce duration equals the accumulated charge time

          ;;
          ;; Input: temp1 = attacker player index (0-3)

          ;; joy0fire/joy1fire (hardware) = fire button sta


          ;; frootyChargeTimer[] (SCRAM w104-w107) = charge timer (0-30)

          ;; frootyChargeState[] (SCRAM w108-w111) = charge state (bit 7=charging, bits 0-2=frame counter)

          ;;
          ;; Output: Charge timer updated or projectile spawned on release

          ;;
          ;; Mutates: temp1-temp6, frootyChargeTimer[], frootyChargeState[],

          ;; missile state (via SpawnMissile on release)

          ;;
          ;; Called Routines: SpawnMissile (bank12) - spawns projectile on release

          ;;
          ;; Constraints: Must check fire button state, handle charge timing at 10 Hz

          ;; Check fire button state based on player index

          ;; Players 0,2 use joy0fire; Players 1,3 use joy1fire

          ;; temp2 = 0 for players 0,2 (joy0fire); 1 for players 1,3 (joy1fire)

          ;; ;; let temp2 = temp1 & 1
          lda temp1
          and # 1
          sta temp2

          ;; lda temp1 (duplicate)
          ;; and # 1 (duplicate)
          ;; sta temp2 (duplicate)


          ;; Player 1 or 3: check joy1fire

          ;; lda temp2 (duplicate)
          cmp # 0
          bne skip_6886
          jmp FrootyCheckJoy0
skip_6886:


          ;; lda joy1fire (duplicate)
          ;; bne skip_4765 (duplicate)
          ;; jmp FrootyButtonReleased (duplicate)
skip_4765:


          ;; jmp FrootyButtonHeld (duplicate)

.pend

FrootyCheckJoy0 .proc

          ;; Player 0 or 2: check joy0fire
          ;; Returns: Far (return otherbank)

          ;; Button is held - continue charging

          ;; lda joy0fire (duplicate)
          ;; bne skip_5594 (duplicate)
          ;; jmp FrootyButtonReleased (duplicate)
skip_5594:


FrootyButtonHeld

          ;; Button is held - increment charge timer at 10 Hz (every 6 frames at 60fps)
          ;; Returns: Far (return otherbank)

          ;; Use per-player frame counter stored in charge state (bits 0-2)

          ;; Increment frame counter, when it reaches 6, increment charge timer and reset counter

          ;; Get current state (bit 7 = charging flag, bits 0-2 = frame counter 0-5)

                    ;; let temp3 = frootyChargeState_R[temp1]         
          ;; lda temp1 (duplicate)
          asl
          tax
          ;; lda frootyChargeState_R,x (duplicate)
          ;; sta temp3 (duplicate)

          ;; Extract frame counter (bits 0-2)

          ;; Increment frame counter

          ;; ;; let temp4 = temp3 & 7
          ;; lda temp3 (duplicate)
          ;; and # 7 (duplicate)
          ;; sta temp4 (duplicate)

          ;; lda temp3 (duplicate)
          ;; and # 7 (duplicate)
          ;; sta temp4 (duplicate)


          ;; Check if frame counter reached 6 (time to increment charge)

          inc temp4

          ;; Frame counter reached 6 - increment charge timer and reset counter

          ;; ;; if temp4 < 6 then goto FrootyUpdateFrameCounter          lda temp4          cmp 6          bcs .skip_7916          jmp
          ;; lda temp4 (duplicate)
          ;; cmp # 6 (duplicate)
          bcs skip_6023
          goto_label:

          ;; jmp goto_label (duplicate)
skip_6023:

          ;; lda temp4 (duplicate)
          ;; cmp # 6 (duplicate)
          ;; bcs skip_5475 (duplicate)
          ;; jmp goto_label (duplicate)
skip_5475:

          

          ;; Increment charge timer (0-30 range, 30 = 3 seconds at 10 Hz)

          ;; lda # 0 (duplicate)
          ;; sta temp4 (duplicate)

          ;; At max charge, don’t increment further, but still update frame counter

                    ;; if frootyChargeTimer_R[temp1] >= 30 then goto FrootyUpdateFrameCounter

                    ;; let frootyChargeTimer_W[temp1] = frootyChargeTimer_R[temp1]
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda frootyChargeTimer_R,x (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; sta frootyChargeTimer_W,x + 1 (duplicate)

.pend

FrootyUpdateFrameCounter .proc

          ;; Update charge state: set charging flag (bit 7) and frame counter (bits 0-2)
          ;; Returns: Far (return otherbank)

          ;; bit 7 = 1 (charging), bits 0-2 = frame counter
          ;; lda 128 (duplicate)
          ora temp4
          ;; sta temp3 (duplicate)

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda temp3 (duplicate)
          ;; sta frootyChargeState_W,x (duplicate)

          ;; jmp FrootyChargeDone (duplicate)



FrootyButtonReleased

          ;; Button released - check if we were charging (bit 7 of charge sta

          ;; Returns: Far (return otherbank)

                    ;; let temp3 = frootyChargeState_R[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda frootyChargeState_R,x (duplicate)
          ;; sta temp3 (duplicate)

          ;; Extract charging flag (bit 7)

          ;; ;; let temp4 = temp3 & 128
          ;; lda temp3 (duplicate)
          ;; and # 128 (duplicate)
          ;; sta temp4 (duplicate)

          ;; lda temp3 (duplicate)
          ;; and # 128 (duplicate)
          ;; sta temp4 (duplicate)


          ;; Was charging - spawn projectile with charge-based lifetime

          ;; lda temp4 (duplicate)
          ;; bne skip_4109 (duplicate)
          ;; jmp FrootyChargeDone (duplicate)
skip_4109:


          ;; Get charge value (0-30)

          ;; Reset charge state and timer

                    ;; let temp2 = frootyChargeTimer_R[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda frootyChargeTimer_R,x (duplicate)
          ;; sta temp2 (duplicate)

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta frootyChargeState_W,x (duplicate)

          ;; Spawn projectile with ricochet physics

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta frootyChargeTimer_W,x (duplicate)

          ;; Use SpawnMissile but override lifetime

          ;; Override missile lifetime with charge time (in frames)

          ;; Cross-bank call to SpawnMissile in bank 7
          ;; lda # >(return_point-1) (duplicate)
          pha
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(SpawnMissile-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(SpawnMissile-1) (duplicate)
          ;; pha (duplicate)
                    ldx # 6
          ;; jmp BS_jsr (duplicate)
return_point:


          ;; Charge is in 10 Hz ticks, convert to frames: charge × 6

          ;; Lifetime = charge × 6 frames (each tick = 0.1s = 6 frames at 60fps)

          ;; Clamp to reasonable range (minimum 6 frames, maximum 180 frames = 3 seconds)

                    ;; let temp3 = temp2 * 6

          ;; ;; if temp3 < 6 then let temp3 = 6
          ;; lda temp3 (duplicate)
          ;; cmp # 6 (duplicate)
          ;; bcs skip_6653 (duplicate)
          ;; jmp let_label (duplicate)
skip_6653:

          ;; lda temp3 (duplicate)
          ;; cmp # 6 (duplicate)
          ;; bcs skip_2633 (duplicate)
          ;; jmp let_label (duplicate)
skip_2633:



          ;; lda temp3 (duplicate)
          ;; cmp # 181 (duplicate)
          bcc skip_8491
          ;; lda # 180 (duplicate)
          ;; sta temp3 (duplicate)
skip_8491:


          ;; Set ricochet velocity - Frooty’s missile will bounce off bounds

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda temp3 (duplicate)
          ;; sta missileLifetime_W,x (duplicate)

          ;; Ricochet logic handled in UpdateOneMissile via bounds checking

          ;; Set animation sta


                    ;; let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionAttackExecuteShifted



FrootyChargeDone
          ;; Returns: Far (return otherbank)
          jsr BS_return

.pend

