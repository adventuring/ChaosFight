          rem ChaosFight - Source/Data/SoundPointers.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem SOUND POINTER DATA TABLES
          rem =================================================================
          rem Sound pointer lookup tables (populated with symbol addresses)
          rem Format: data SoundPointersL, SoundPointersH tables (10 entries: indices 0-9)
          rem Sounds: 0=AttackHit, 1=GuardBlock, 2=Jump, 3=PlayerEliminated, 4=MenuNavigate,
          rem   5=MenuSelect, 6=SpecialMove, 7=Powerup, 8=LandingSafe, 9=LandingDamage
          rem =================================================================
          
          data SoundPointersL
          <Sound_SoundAttackHit_Voice0, <Sound_SoundGuardBlock_Voice0, <Sound_SoundJump_Voice0, <Sound_SoundPlayerEliminated_Voice0, <Sound_SoundMenuNavigate_Voice0
          <Sound_SoundMenuSelect_Voice0, <Sound_SoundSpecialMove_Voice0, <Sound_SoundPowerup_Voice0, <Sound_SoundLandingSafe_Voice0, <Sound_SoundLandingDamage_Voice0
          end
          data SoundPointersH
          >Sound_SoundAttackHit_Voice0, >Sound_SoundGuardBlock_Voice0, >Sound_SoundJump_Voice0, >Sound_SoundPlayerEliminated_Voice0, >Sound_SoundMenuNavigate_Voice0
          >Sound_SoundMenuSelect_Voice0, >Sound_SoundSpecialMove_Voice0, >Sound_SoundPowerup_Voice0, >Sound_SoundLandingSafe_Voice0, >Sound_SoundLandingDamage_Voice0
          end
