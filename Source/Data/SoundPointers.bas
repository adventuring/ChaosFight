          rem
          rem ChaosFight - Source/Data/SoundPointers.bas
          rem Copyright (c) 2025 Interworldly Adventuring, LLC.
          
          rem Sound Pointer Data Tables
          rem Sound pointer lookup tables (populated with symbol
          rem   addresses)
          rem Format: data SoundPointersL, SoundPointersH tables (10
          rem   entries: indices 0-9)
          rem Sounds: 0=AttackHit, 1=GuardBlock, 2=Jump,
          rem   3=PlayerEliminated, 4=MenuNavigate,
          rem 5=MenuSelect, 6=SpecialMove, 7=Powerup, 8=LandingSafe,
          rem   9=LandingDamage
          
          data SoundPointersL
            <Sound_SoundAttackHit, <Sound_SoundGuardBlock, <Sound_SoundJump, <Sound_SoundPlayerEliminated, <Sound_SoundMenuNavigate,
            <Sound_SoundMenuSelect, <Sound_SoundSpecialMove, <Sound_SoundPowerup, <Sound_SoundLandingSafe, <Sound_SoundLandingDamage
end
          data SoundPointersH
            >Sound_SoundAttackHit, >Sound_SoundGuardBlock, >Sound_SoundJump, >Sound_SoundPlayerEliminated, >Sound_SoundMenuNavigate,
            >Sound_SoundMenuSelect, >Sound_SoundSpecialMove, >Sound_SoundPowerup, >Sound_SoundLandingSafe, >Sound_SoundLandingDamage
end
