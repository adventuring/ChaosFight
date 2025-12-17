;;; ChaosFight - Source/Routines/FrootyAttack.bas


;;; Copyright © 2025 Bruce-Robert Pocock.

;;; Issue #1177: Frooty lollipop charge-and-bounce attack




          ;; Forward declarations for labels defined later

          ;; Forward declarations
FrootyButtonHeld:
FrootyButtonReleased:

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

          ;; Set temp2 = temp1 & 1
          lda temp1
          and # 1
          sta temp2

          lda temp1
          and # 1
          sta temp2


          ;; Player 1 or 3: check joy1fire

          lda temp2
          bne CheckJoy1Fire
          jmp FrootyCheckJoy0
CheckJoy1Fire:


          lda INPT4
          bne FrootyButtonHeld
          jmp FrootyButtonReleased


          jmp FrootyButtonHeld

.pend

FrootyCheckJoy0 .proc

          ;; Player 0 or 2: check joy0fire
          ;; Returns: Far (return otherbank)

          ;; Button is held - continue charging

          lda INPT0
          bne FrootyButtonHeld
          jmp FrootyButtonReleased



          ;; Button is held - increment charge timer at 10 Hz (every 6 frames at 60fps)
          ;; Returns: Far (return otherbank)

          ;; Use per-player frame counter stored in charge state (bits 0-2)

          ;; Increment frame counter, when it reaches 6, increment charge timer and reset counter

          ;; Get current state (bit 7 = charging flag, bits 0-2 = frame counter 0-5)

          ;; Set temp3 = frootyChargeState_R[temp1]
          lda temp1
          asl
          tax
          lda frootyChargeState_R,x
          sta temp3

          ;; Extract frame counter (bits 0-2)

          ;; Increment frame counter

          ;; Set temp4 = temp3 & 7
          lda temp3
          and # 7
          sta temp4

          ;; Check if frame counter reached 6 (time to increment charge)
          inc temp4

          ;; Frame counter reached 6 - increment charge timer and reset counter

          ;; if temp4 < 6 then jmp FrootyUpdateFrameCounter
          lda temp4
          cmp # 6
          bcs IncrementChargeTimer
          jmp FrootyUpdateFrameCounter
IncrementChargeTimer:

          

          ;; Increment charge timer (0-30 range, 30 = 3 seconds at 10 Hz)

          ;; At max charge, don't increment further, but still update frame counter
          lda temp1
          asl
          tax
          lda frootyChargeTimer_R,x
          cmp # 30
          bcs ResetFrameCounter  ; Max charge reached, don't increment

          ;; let frootyChargeTimer_W[temp1] = frootyChargeTimer_R[temp1] + 1
          lda frootyChargeTimer_R,x
          clc
          adc # 1
          sta frootyChargeTimer_W,x

ResetFrameCounter:
          ;; Reset frame counter to 0 for next 6-frame cycle
          lda # 0
          sta temp4
          ;; Fall through to FrootyUpdateFrameCounter
          jmp FrootyUpdateFrameCounter

.pend

FrootyUpdateFrameCounter .proc

          ;; Update charge state: set charging flag (bit 7) and frame counter (bits 0-2)
          ;; Returns: Far (return otherbank)

          ;; bit 7 = 1 (charging), bits 0-2 = frame counter
          lda # 128
          ora temp4
          sta temp3

          lda temp1
          asl
          tax
          lda temp3
          sta frootyChargeState_W,x

          jmp FrootyChargeDone




          ;; Button released - check if we were charging (bit 7 of charge sta

          ;; Returns: Far (return otherbank)

          ;; Set temp3 = frootyChargeState_R[temp1]
          lda temp1
          asl
          tax
          lda frootyChargeState_R,x
          sta temp3

          ;; Extract charging flag (bit 7)

          ;; Set temp4 = temp3 & 128
          lda temp3
          and # 128
          sta temp4

          lda temp3
          and # 128
          sta temp4


          ;; Was charging - spawn projectile with charge-based lifetime

          lda temp4
          bne SpawnProjectile
          jmp FrootyChargeDone
SpawnProjectile:


          ;; Get charge value (0-30)

          ;; Reset charge state and timer

          ;; Set temp2 = frootyChargeTimer_R[temp1]
          lda temp1
          asl
          tax
          lda frootyChargeTimer_R,x
          sta temp2

          lda temp1
          asl
          tax
          lda # 0
          sta frootyChargeState_W,x

          ;; Spawn projectile with ricochet physics

          lda temp1
          asl
          tax
          lda # 0
          sta frootyChargeTimer_W,x

          ;; Use SpawnMissile but override lifetime

          ;; Override missile lifetime with charge time (in frames)

          ;; Cross-bank call to SpawnMissile in bank 6
          ;; Return address: ENCODED with caller bank 7 ($70) for BS_return to decode
          lda # ((>(AfterSpawnMissileFrooty-1)) & $0f) | $70  ;;; Encode bank 7 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterSpawnMissileFrooty hi (encoded)]
          lda # <(AfterSpawnMissileFrooty-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterSpawnMissileFrooty hi (encoded)] [SP+0: AfterSpawnMissileFrooty lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(SpawnMissile-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterSpawnMissileFrooty hi (encoded)] [SP+1: AfterSpawnMissileFrooty lo] [SP+0: SpawnMissile hi (raw)]
          lda # <(SpawnMissile-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterSpawnMissileFrooty hi (encoded)] [SP+2: AfterSpawnMissileFrooty lo] [SP+1: SpawnMissile hi (raw)] [SP+0: SpawnMissile lo]
          ldx # 6
          jmp BS_jsr
AfterSpawnMissileFrooty:


          ;; Charge is in 10 Hz ticks, convert to frames: charge × 6

          ;; Lifetime = charge * 6 frames (each tick = 0.1s = 6 frames at 60fps)

          ;; Clamp to reasonable range (minimum 6 frames, maximum 180 frames = 3 seconds)

          ;; Set temp3 = temp2 * 6
          ;; If temp3 < 6, set temp3 = 6
          lda temp3
          cmp # 6
          bcs CheckMaximumLifetime
          ;; jmp let_label
CheckMaximumLifetime:

          lda temp3
          cmp # 6
          bcs CheckMaximumLifetimeDone
          ;; jmp let_label
CheckMaximumLifetimeDone:



          lda temp3
          cmp # 181
          bcc SetMissileLifetime
          lda # 180
          sta temp3
SetMissileLifetime:


          ;; Set ricochet velocity - Frooty’s missile will bounce off bounds

          lda temp1
          asl
          tax
          lda temp3
          sta missileLifetime_W,x

          ;; Ricochet logic handled in UpdateOneMissile via bounds checking

          ;; Set animation sta


          ;; let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionAttackExecuteShifted



FrootyChargeDone
          ;; Returns: Far (return otherbank)
          jmp BS_return

.pend

