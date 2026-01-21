Sound_rem_label_1:

;;; ChaosFight - Source/Data/SoundPointers.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

          ;; Sound Pointer Data Tables
          ;; Sound pointer lookup tables (populated with symbol
          ;; addresses)
          ;; Format: data SoundPointersL, SoundPointersH tables (10
          ;; entries: indices 0-9)
          ;; Sounds: 0=AttackHit, 1=GuardBlock, 2=Jump,
          ;; 3=PlayerEliminated, 4=MenuNavigate,
          ;; 5=MenuSelect, 6=SpecialMove, 7=Powerup, 8=LandingSafe,
          ;; 9=LandingDamage

SoundPointersL:
          .byte <Sound_SoundAttackHit, <Sound_SoundGuardBlock, <Sound_SoundJump, <Sound_SoundPlayerEliminated, <Sound_SoundMenuNavigate, <Sound_SoundMenuSelect, <Sound_SoundSpecialMove, <Sound_SoundPowerup, <Sound_SoundLandingSafe, <Sound_SoundLandingDamage
SoundPointersL_end:
SoundPointersH:
          .byte >Sound_SoundAttackHit, >Sound_SoundGuardBlock, >Sound_SoundJump, >Sound_SoundPlayerEliminated, >Sound_SoundMenuNavigate, >Sound_SoundMenuSelect, >Sound_SoundSpecialMove, >Sound_SoundPowerup, >Sound_SoundLandingSafe, >Sound_SoundLandingDamage
SoundPointersH_end:
