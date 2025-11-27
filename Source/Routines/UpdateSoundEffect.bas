          rem ChaosFight - Source/Routines/UpdateSoundEffect.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

UpdateSoundEffect
          rem Returns: Far (return otherbank)
          asm
UpdateSoundEffect
end
          rem UpdateSoundEffect - Update sound effect playback each
          rem Returns: Far (return otherbank)
          rem   frame
          rem Called every frame from MainLoop for gameMode 6
          rem Updates both voices if active (high byte != 0)
          rem Update sound effect playback each frame (called every
          rem frame from MainLoop for gameMode 6)
          rem
          rem Input: soundEffectPointer, soundEffectPointer1 (global 16-bit)
          rem = sound effect pointers, soundEffectFrame_R,
          rem soundEffectFrame1_R (global SCRAM) = frame counters
          rem
          rem Output: Both voices updated if active (high byte != 0)
          rem
          rem Mutates: All sound effect state (via
          rem UpdateSoundEffectVoice0 and UpdateSoundEffectVoice1)
          rem
          rem Called Routines: UpdateSoundEffectVoice0 - updates Voice 0
          rem if active, UpdateSoundEffectVoice1 - updates Voice 1 if
          rem active
          rem
          rem Constraints: Called every frame from MainLoop for gameMode
          rem 6. Only updates voices if active (high byte != 0)
          rem Update Voice 0
          if soundEffectPointer then gosub UpdateSoundEffectVoice0 bank15

          rem Update Voice 1

          if soundEffectPointer1 then gosub UpdateSoundEffectVoice1 bank15
          return otherbank

