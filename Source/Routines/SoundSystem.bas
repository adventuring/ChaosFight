          rem ChaosFight - Source/Routines/SoundSystem.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem =================================================================
          rem SOUND SUBSYSTEM - STUB PLACEHOLDER
          rem =================================================================
          rem NOTE: Complete sound/music subsystem implementation pending.
          rem      This is a temporary placeholder that delays and returns.
          rem      See GitHub issues #162, #243, #306 for requirements.
          rem
          rem TODO: Implement full polyphony 2 music + polyphony 1 sound effects
          rem      - Music must come from assets, not hard-coded
          rem      - Proper TIA audio channel sharing
          rem      - Sound effects first-come, first-served

          rem =================================================================
          rem SOUND SUBSYSTEM STUB
          rem =================================================================
          rem Simple countdown loop that waits 256 iterations and returns
SoundSubsystem
          temp1 = 0
SoundSubsystemLoop
          temp1 = temp1 + 1
          if temp1 > 0 then goto SoundSubsystemLoop
          return

          rem =================================================================
          rem COMPATIBILITY STUBS
          rem =================================================================
          rem These are called from various game routines

PlaySoundEffect
          return

StopSoundEffects
          return
