          rem ChaosFight - Source/Banks/Bank15.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          bank 15
          
          rem Sound effects system - dedicated 3.5kiB bank for compiled samples
          #include "Source/Routines/SoundSystem.bas"

          rem =================================================================
          rem SOUNDS BANK HELPER FUNCTIONS
          rem =================================================================
          rem These functions access sound data tables and streams in this bank
          rem =================================================================
          
          rem Sound pointer lookup tables (populated with symbol addresses)
          rem Format: data SoundPointersL, SoundPointersH tables (10 entries: indices 0-9)
          rem Sounds: 0=AttackHit, 1=GuardBlock, 2=Jump, 3=PlayerEliminated, 4=MenuNavigate,
          rem   5=MenuSelect, 6=SpecialMove, 7=Powerup, 8=LandingSafe, 9=LandingDamage
          data SoundPointersL
          <Sound_SoundAttackHit_Voice0, <Sound_SoundGuardBlock_Voice0, <Sound_SoundJump_Voice0, <Sound_SoundPlayerEliminated_Voice0, <Sound_SoundMenuNavigate_Voice0
          <Sound_SoundMenuSelect_Voice0, <Sound_SoundSpecialMove_Voice0, <Sound_SoundPowerup_Voice0, <Sound_SoundLandingSafe_Voice0, <Sound_SoundLandingDamage_Voice0
          end
          data SoundPointersH
          >Sound_SoundAttackHit_Voice0, >Sound_SoundGuardBlock_Voice0, >Sound_SoundJump_Voice0, >Sound_SoundPlayerEliminated_Voice0, >Sound_SoundMenuNavigate_Voice0
          >Sound_SoundMenuSelect_Voice0, >Sound_SoundSpecialMove_Voice0, >Sound_SoundPowerup_Voice0, >Sound_SoundLandingSafe_Voice0, >Sound_SoundLandingDamage_Voice0
          end
          
          rem Lookup sound pointer from tables
          rem Input: temp1 = sound ID (0-9)
          rem Output: SoundPointerL, SoundPointerH = pointer to Sound_Voice0 stream
LoadSoundPointer
          rem Bounds check: only 10 sounds (0-9)
          if temp1 > 9 then let SoundPointerH = 0 : return
          rem Use array access to lookup pointer
          let SoundPointerL = SoundPointersL[temp1]
          let SoundPointerH = SoundPointersH[temp1]
          return
          
          rem Load next note from sound effect stream using assembly for pointer access
          rem Input: SoundEffectPointerL/H points to current note in Sound_Voice0 stream
          rem Output: Updates TIA registers, advances pointer, sets SoundEffectFrame
LoadSoundNote
          asm
          ; Load 4 bytes from stream[pointer]
          ldy #0
          lda (SoundEffectPointerL),y  ; Load AUDCV
          sta temp2
          iny
          lda (SoundEffectPointerL),y  ; Load AUDF
          sta temp3
          iny
          lda (SoundEffectPointerL),y  ; Load Duration
          sta temp4
          iny
          lda (SoundEffectPointerL),y  ; Load Delay
          sta temp5
          end
          
          rem Check for end of sound (Duration = 0)
          if temp4 = 0 then let SoundEffectPointerH = 0 : AUDV0 = 0 : return
          
          rem Extract AUDC (upper 4 bits) and AUDV (lower 4 bits) from AUDCV
          temp6 = temp2 & %11110000
          temp6 = temp6 / 16
          temp7 = temp2 & %00001111
          
          rem Write to TIA registers (use Voice 0 for sound effects)
          AUDC0 = temp6
          AUDF0 = temp3
          AUDV0 = temp7
          
          rem Set frame counter = Duration + Delay
          let SoundEffectFrame = temp4 + temp5
          
          rem Advance pointer by 4 bytes (16-bit addition)
          let temp2 = SoundEffectPointerL
          let SoundEffectPointerL = temp2 + 4
          if SoundEffectPointerL < temp2 then let SoundEffectPointerH = SoundEffectPointerH + 1
          
          return
          
          rem Load next note from sound effect stream for Voice 1
          rem Input: SoundEffectPointer1L/H points to current note in Sound_Voice0 stream
          rem Output: Updates TIA registers, advances pointer, sets SoundEffectFrame1
LoadSoundNote1
          asm
          ; Load 4 bytes from stream[pointer]
          ldy #0
          lda (SoundEffectPointer1L),y  ; Load AUDCV
          sta temp2
          iny
          lda (SoundEffectPointer1L),y  ; Load AUDF
          sta temp3
          iny
          lda (SoundEffectPointer1L),y  ; Load Duration
          sta temp4
          iny
          lda (SoundEffectPointer1L),y  ; Load Delay
          sta temp5
          end
          
          rem Check for end of sound (Duration = 0)
          if temp4 = 0 then let SoundEffectPointer1H = 0 : AUDV1 = 0 : return
          
          rem Extract AUDC (upper 4 bits) and AUDV (lower 4 bits) from AUDCV
          temp6 = temp2 & %11110000
          temp6 = temp6 / 16
          temp7 = temp2 & %00001111
          
          rem Write to TIA registers (use Voice 1 for sound effects)
          AUDC1 = temp6
          AUDF1 = temp3
          AUDV1 = temp7
          
          rem Set frame counter = Duration + Delay
          let SoundEffectFrame1 = temp4 + temp5
          
          rem Advance pointer by 4 bytes (16-bit addition)
          let temp2 = SoundEffectPointer1L
          let SoundEffectPointer1L = temp2 + 4
          if SoundEffectPointer1L < temp2 then let SoundEffectPointer1H = SoundEffectPointer1H + 1
          
          return
          
          rem =================================================================
          rem SOUND EFFECT DATA (Generated by SkylineTool)
          rem =================================================================
          rem Note: Pointer tables must be updated with actual addresses after compilation
          rem Sounds are indexed: 0=SoundAttackHit, 1=SoundGuardBlock, 2=SoundJump,
          rem   3=SoundPlayerEliminated, 4=SoundMenuNavigate, 5=SoundMenuSelect,
          rem   6=SoundSpecialMove, 7=SoundPowerup, 8=SoundLandingSafe, 9=SoundLandingDamage
          
          rem Sound 0: Attack Hit
          #ifdef TV_NTSC
          #include "Source/Generated/Sound.SoundAttackHit.NTSC.bas"
          #else
          rem PAL or SECAM: Use PAL version for both
          #include "Source/Generated/Sound.SoundAttackHit.PAL.bas"
          #endif
          
          rem Sound 1: Guard Block
          #ifdef TV_NTSC
          #include "Source/Generated/Sound.SoundGuardBlock.NTSC.bas"
          #else
          rem PAL or SECAM: Use PAL version for both
          #include "Source/Generated/Sound.SoundGuardBlock.PAL.bas"
          #endif
          
          rem Sound 2: Jump
          #ifdef TV_NTSC
          #include "Source/Generated/Sound.SoundJump.NTSC.bas"
          #else
          rem PAL or SECAM: Use PAL version for both
          #include "Source/Generated/Sound.SoundJump.PAL.bas"
          #endif
          
          rem Sound 3: Player Eliminated
          #ifdef TV_NTSC
          #include "Source/Generated/Sound.SoundPlayerEliminated.NTSC.bas"
          #else
          rem PAL or SECAM: Use PAL version for both
          #include "Source/Generated/Sound.SoundPlayerEliminated.PAL.bas"
          #endif
          
          rem Sound 4: Menu Navigate
          #ifdef TV_NTSC
          #include "Source/Generated/Sound.SoundMenuNavigate.NTSC.bas"
          #else
          rem PAL or SECAM: Use PAL version for both
          #include "Source/Generated/Sound.SoundMenuNavigate.PAL.bas"
          #endif
          
          rem Sound 5: Menu Select
          #ifdef TV_NTSC
          #include "Source/Generated/Sound.SoundMenuSelect.NTSC.bas"
          #else
          rem PAL or SECAM: Use PAL version for both
          #include "Source/Generated/Sound.SoundMenuSelect.PAL.bas"
          #endif
          
          rem Sound 6: Special Move
          #ifdef TV_NTSC
          #include "Source/Generated/Sound.SoundSpecialMove.NTSC.bas"
          #else
          rem PAL or SECAM: Use PAL version for both
          #include "Source/Generated/Sound.SoundSpecialMove.PAL.bas"
          #endif
          
          rem Sound 7: Powerup
          #ifdef TV_NTSC
          #include "Source/Generated/Sound.SoundPowerup.NTSC.bas"
          #else
          rem PAL or SECAM: Use PAL version for both
          #include "Source/Generated/Sound.SoundPowerup.PAL.bas"
          #endif
          
          rem Sound 8: Landing Safe
          #ifdef TV_NTSC
          #include "Source/Generated/Sound.SoundLandingSafe.NTSC.bas"
          #else
          rem PAL or SECAM: Use PAL version for both
          #include "Source/Generated/Sound.SoundLandingSafe.PAL.bas"
          #endif
          
          rem Sound 9: Landing Damage
          #ifdef TV_NTSC
          #include "Source/Generated/Sound.SoundLandingDamage.NTSC.bas"
          #else
          rem PAL or SECAM: Use PAL version for both
          #include "Source/Generated/Sound.SoundLandingDamage.PAL.bas"
          #endif

