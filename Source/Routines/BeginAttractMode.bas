BeginAttractMode
          asm
BeginAttractMode

end
          rem
          rem ChaosFight - Source/Routines/BeginAttractMode.bas
          rem Copyright © 2025 Bruce-Robert Pocock.
          rem BEGIN ATTRACT MODE - Setup Routine
          rem
          rem Setup routine for Attract Mode. Sets initial state only.
          rem Called from ChangeGameMode when transitioning to
          rem   ModeAttract.
          rem Attract mode is entered after 3 minutes of title screen
          rem   inactivity.
          rem It automatically loops back to Publisher Prelude to
          rem   restart the sequence.
          rem Setup routine for Attract Mode - sets initial state only
          rem
          rem Input: None (called from ChangeGameMode)
          rem
          rem Output: COLUBK set
          rem
          rem Mutates: COLUBK (TIA register)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Called from ChangeGameMode when transitioning
          rem to ModeAttract
          rem              Attract mode immediately transitions to
          rem              Publisher Prelude (handled in AttractMode
          rem              loop)
          rem Initialize Attract Mode
          rem Background: black (COLUBK starts black, no need to set)
          rem BeginAttractMode is called same-bank from SetupAttract (both in bank14)
          rem SetupAttract uses gosub (same-bank call, pushes 2 bytes), so return thisbank is correct
          rem SetupAttract itself returns with return thisbank to handle the cross-bank call to ChangeGameMode
          return thisbank
          rem Reset title screen timers for next cycle
          rem titleParadeTimer will be reset when we return to title
          rem   screen
          rem Note: Attract mode immediately transitions to Publisher
          rem   Prelude
          rem This is handled in the AttractMode loop
