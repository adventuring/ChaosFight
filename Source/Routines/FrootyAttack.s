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

          ;; let temp2 = temp1 & 1
          lda temp1
          and # 1
          sta temp2

          lda temp1
          and # 1
          sta temp2


          ;; Player 1 or 3: check joy1fire

          lda temp2
          cmp # 0
          bne skip_6886
          jmp FrootyCheckJoy0
skip_6886:


          lda joy1fire
          bne skip_4765
          jmp FrootyButtonReleased
skip_4765:


          jmp FrootyButtonHeld

.pend

FrootyCheckJoy0 .proc

          ;; Player 0 or 2: check joy0fire
          ;; Returns: Far (return otherbank)

          ;; Button is held - continue charging

          lda joy0fire
          bne skip_5594
          jmp FrootyButtonReleased
skip_5594:


FrootyButtonHeld

          ;; Button is held - increment charge timer at 10 Hz (every 6 frames at 60fps)
          ;; Returns: Far (return otherbank)

          ;; Use per-player frame counter stored in charge state (bits 0-2)

          ;; Increment frame counter, when it reaches 6, increment charge timer and reset counter

          ;; Get current state (bit 7 = charging flag, bits 0-2 = frame counter 0-5)

                    let temp3 = frootyChargeState_R[temp1]         
          lda temp1
          asl
          tax
          lda frootyChargeState_R,x
          sta temp3

          ;; Extract frame counter (bits 0-2)

          ;; Increment frame counter

          ;; let temp4 = temp3 & 7
          lda temp3
          and # 7
          sta temp4

          lda temp3
          and # 7
          sta temp4


          ;; Check if frame counter reached 6 (time to increment charge)

          inc temp4

          ;; Frame counter reached 6 - increment charge timer and reset counter

          ;; if temp4 < 6 then goto FrootyUpdateFrameCounter          lda temp4          cmp 6          bcs .skip_7916          jmp
          lda temp4
          cmp # 6
          bcs skip_6023
          goto_label:

          jmp goto_label
skip_6023:

          lda temp4
          cmp # 6
          bcs skip_5475
          jmp goto_label
skip_5475:

          

          ;; Increment charge timer (0-30 range, 30 = 3 seconds at 10 Hz)

          lda # 0
          sta temp4

          ;; At max charge, don’t increment further, but still update frame counter

                    if frootyChargeTimer_R[temp1] >= 30 then goto FrootyUpdateFrameCounter

                    let frootyChargeTimer_W[temp1] = frootyChargeTimer_R[temp1]
          lda temp1
          asl
          tax
          lda frootyChargeTimer_R,x
          lda temp1
          asl
          tax
          sta frootyChargeTimer_W,x + 1

.pend

FrootyUpdateFrameCounter .proc

          ;; Update charge state: set charging flag (bit 7) and frame counter (bits 0-2)
          ;; Returns: Far (return otherbank)

          bit 7 = 1 (charging), bits 0-2 = frame counter
          lda 128
          ora temp4
          sta temp3

          lda temp1
          asl
          tax
          lda temp3
          sta frootyChargeState_W,x

          jmp FrootyChargeDone



FrootyButtonReleased

          ;; Button released - check if we were charging (bit 7 of charge sta

          ;; Returns: Far (return otherbank)

                    let temp3 = frootyChargeState_R[temp1]         
          lda temp1
          asl
          tax
          lda frootyChargeState_R,x
          sta temp3

          ;; Extract charging flag (bit 7)

          ;; let temp4 = temp3 & 128
          lda temp3
          and # 128
          sta temp4

          lda temp3
          and # 128
          sta temp4


          ;; Was charging - spawn projectile with charge-based lifetime

          lda temp4
          bne skip_4109
          jmp FrootyChargeDone
skip_4109:


          ;; Get charge value (0-30)

          ;; Reset charge state and timer

                    let temp2 = frootyChargeTimer_R[temp1]         
          lda temp1
          asl
          tax
          lda frootyChargeTimer_R,x
          sta temp2

          lda temp1
          asl
          tax
          lda 0
          sta frootyChargeState_W,x

          ;; Spawn projectile with ricochet physics

          lda temp1
          asl
          tax
          lda 0
          sta frootyChargeTimer_W,x

          ;; Use SpawnMissile but override lifetime

          ;; Override missile lifetime with charge time (in frames)

          ;; Cross-bank call to SpawnMissile in bank 7
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(SpawnMissile-1)
          pha
          lda # <(SpawnMissile-1)
          pha
                    ldx # 6
          jmp BS_jsr
return_point:


          ;; Charge is in 10 Hz ticks, convert to frames: charge × 6

          Lifetime = charge × 6 frames (each tick = 0.1s = 6 frames at 60fps)

          ;; Clamp to reasonable range (minimum 6 frames, maximum 180 frames = 3 seconds)

                    let temp3 = temp2 * 6

          ;; if temp3 < 6 then let temp3 = 6
          lda temp3
          cmp # 6
          bcs skip_6653
          jmp let_label
skip_6653:

          lda temp3
          cmp # 6
          bcs skip_2633
          jmp let_label
skip_2633:



          lda temp3
          cmp # 181
          bcc skip_8491
          lda # 180
          sta temp3
skip_8491:


          ;; Set ricochet velocity - Frooty’s missile will bounce off bounds

          lda temp1
          asl
          tax
          lda temp3
          sta missileLifetime_W,x

          ;; Ricochet logic handled in UpdateOneMissile via bounds checking

          ;; Set animation sta


                    let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionAttackExecuteShifted



FrootyChargeDone
          ;; Returns: Far (return otherbank)
          jsr BS_return

.pend

