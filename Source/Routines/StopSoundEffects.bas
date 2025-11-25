          rem ChaosFight - Source/Routines/StopSoundEffects.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

StopSoundEffects
          rem
          rem Stopsoundeffects - Stop All Sound Effects
          rem Stop all sound effects (zeroes TIA volumes, clears
          rem pointers, resets frame counters)
          rem
          rem Input: None
          rem
          rem Output: All sound effects stopped, voices freed
          rem
          rem Mutates: AUDV0, AUDV1 (TIA registers) = sound volumes (set
          rem to 0), soundEffectPointer, soundEffectPointer1 (global 16-bit)
          rem = sound pointers (set to 0), soundEffectFrame_W,
          rem soundEffectFrame1_W (global SCRAM) = frame counters (set
          rem to 0)
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          rem Zero TIA volumes
          AUDV0 = 0
          AUDV1 = 0

          rem Clear sound pointers (high byte = 0 means inactive)
          let soundEffectPointer = 0
          let soundEffectPointer1 = 0

          rem Reset frame counters
          let soundEffectFrame_W = 0
          let soundEffectFrame1_W = 0
          return

