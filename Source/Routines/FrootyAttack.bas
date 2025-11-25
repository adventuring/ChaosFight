          rem ChaosFight - Source/Routines/FrootyAttack.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Issue #1177: Frooty lollipop charge-and-bounce attack

FrootyAttack
          asm
FrootyAttack
end
          rem Issue #1177: Frooty lollipop charge-and-bounce attack
          rem Charge meter advances at 10 Hz (every 0.1s) while action button is held
          rem Maximum charge duration approximately 3 seconds (30 ticks)
          rem On button release, spawn and launch the lollipop projectile
          rem Projectile ricochets off arena bounds like a Breakout/Pong ball
          rem Bounce duration equals the accumulated charge time
          rem
          rem Input: temp1 = attacker player index (0-3)
          rem        joy0fire/joy1fire (hardware) = fire button state
          rem        frootyChargeTimer[] (SCRAM w104-w107) = charge timer (0-30)
          rem        frootyChargeState[] (SCRAM w108-w111) = charge state (bit 7=charging, bits 0-2=frame counter)
          rem
          rem Output: Charge timer updated or projectile spawned on release
          rem
          rem Mutates: temp1-temp6, frootyChargeTimer[], frootyChargeState[],
          rem         missile state (via SpawnMissile on release)
          rem
          rem Called Routines: SpawnMissile (bank12) - spawns projectile on release
          rem
          rem Constraints: Must check fire button state, handle charge timing at 10 Hz
          rem Check fire button state based on player index
          rem Players 0,2 use joy0fire; Players 1,3 use joy1fire
          rem temp2 = 0 for players 0,2 (joy0fire); 1 for players 1,3 (joy1fire)
          let temp2 = temp1 & 1
          rem Player 1 or 3: check joy1fire
          if temp2 = 0 then goto FrootyCheckJoy0
          if !joy1fire then goto FrootyButtonReleased
          goto FrootyButtonHeld
FrootyCheckJoy0
          rem Player 0 or 2: check joy0fire
          rem Button is held - continue charging
          if !joy0fire then goto FrootyButtonReleased
FrootyButtonHeld
          rem Button is held - increment charge timer at 10 Hz (every 6 frames at 60fps)
          rem Use per-player frame counter stored in charge state (bits 0-2)
          rem Increment frame counter, when it reaches 6, increment charge timer and reset counter
          rem Get current state (bit 7 = charging flag, bits 0-2 = frame counter 0-5)
          let temp3 = frootyChargeState_R[temp1]
          rem Extract frame counter (bits 0-2)
          rem Increment frame counter
          let temp4 = temp3 & 7
          rem Check if frame counter reached 6 (time to increment charge)
          let temp4 = temp4 + 1
          rem Frame counter reached 6 - increment charge timer and reset counter
          if temp4 < 6 then goto FrootyUpdateFrameCounter
          rem Increment charge timer (0-30 range, 30 = 3 seconds at 10 Hz)
          let temp4 = 0
          rem At max charge, don’t increment further, but still update frame counter
          if frootyChargeTimer_R[temp1] >= 30 then goto FrootyUpdateFrameCounter
          let frootyChargeTimer_W[temp1] = frootyChargeTimer_R[temp1] + 1
FrootyUpdateFrameCounter
          rem Update charge state: set charging flag (bit 7) and frame counter (bits 0-2)
          rem Bit 7 = 1 (charging), bits 0-2 = frame counter
          let temp3 = 128 | temp4
          let frootyChargeState_W[temp1] = temp3
          goto FrootyChargeDone

FrootyButtonReleased
          rem Button released - check if we were charging (bit 7 of charge state)
          let temp3 = frootyChargeState_R[temp1]
          rem Extract charging flag (bit 7)
          let temp4 = temp3 & 128
          rem Was charging - spawn projectile with charge-based lifetime
          if !temp4 then goto FrootyChargeDone
          rem Get charge value (0-30)
          rem Reset charge state and timer
          let temp2 = frootyChargeTimer_R[temp1]
          let frootyChargeState_W[temp1] = 0
          rem Spawn projectile with ricochet physics
          let frootyChargeTimer_W[temp1] = 0
          rem Use SpawnMissile but override lifetime
          rem Override missile lifetime with charge time (in frames)
          gosub SpawnMissile bank7
          rem Charge is in 10 Hz ticks, convert to frames: charge * 6
          rem Lifetime = charge * 6 frames (each tick = 0.1s = 6 frames at 60fps)
          rem Clamp to reasonable range (minimum 6 frames, maximum 180 frames = 3 seconds)
          let temp3 = temp2 * 6
          if temp3 < 6 then temp3 = 6
          if temp3 > 180 then temp3 = 180
          rem Set ricochet velocity - Frooty’s missile will bounce off bounds
          let missileLifetime_W[temp1] = temp3
          rem Ricochet logic handled in UpdateOneMissile via bounds checking
          rem Set animation state
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionAttackExecuteShifted

FrootyChargeDone
          return otherbank

