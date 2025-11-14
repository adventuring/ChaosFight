          rem ChaosFight - Source/Routines/LoadSoundPointer.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

LoadSoundPointer
          asm
LoadSoundPointer

end
          rem Lookup sound pointer from tables (Bank 15 sounds: 0-9)
          rem
          rem Input: temp1 = sound ID (0-9), SoundPointersL[],
          rem SoundPointersH[] (global data tables) = sound pointer
          rem tables
          rem
          rem Output: soundPointer = pointer to Sound_Voice0 stream
          rem
          rem Mutates: temp1 (used for sound ID), soundPointer
          rem
          rem Called Routines: None
          rem
          rem Constraints: Only 10 sounds (0-9) available. Returns
          rem soundPointer = 0 if sound ID out of bounds
          rem Bounds check: only 10 sounds (0-9)
          if temp1 > 9 then goto LoadSoundPointerOutOfRange
          let soundPointer = SoundPointersH[temp1]
          let soundPointer = soundPointer * 256
          let soundPointer = soundPointer + SoundPointersL[temp1]
          goto LoadSoundPointerReturn
LoadSoundPointerOutOfRange
          let soundPointer = 0
          rem Out of range - mark sound pointer inactive
LoadSoundPointerReturn
          return

