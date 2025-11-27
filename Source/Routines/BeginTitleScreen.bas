BeginTitleScreen
          asm
BeginTitleScreen

end
          rem ChaosFight - Source/Routines/BeginTitleScreen.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

          rem Setup routine for Title Screen. Sets initial state only.

          rem Setup routine for Title Screen - sets initial state only
          rem
          rem Input: None (called from ChangeGameMode)
          rem
          rem Output: titleParadeTimer initialized, titleParadeActive
          rem initialized, COLUBK set,
          rem         music started, window values set
          rem
          rem Mutates: titleParadeTimer (set to 0), titleParadeActive
          rem (set to 0),
          rem         COLUBK (TIA register), temp1 (passed to
          rem         StartMusic)
          rem
          rem Called Routines: StartMusic (bank1) - starts title music,
          rem   SetTitleWindowValues (bank14) - sets window values
          rem
          rem Constraints: Called from ChangeGameMode when transitioning
          rem to ModeTitle
          rem Initialize Title Screen mode
          rem Note: pfres is defined globally in AssemblyConfig.bas

          rem Initialize title parade state
          let titleParadeTimer = 0
          let titleParadeActive = 0

          rem Background: black (COLUBK starts black, no need to set)

          rem Start Chaotica title music
          let temp1 = MusicChaotica
          gosub StartMusic bank15

          rem Set window values for Title screen (ChaosFight only)
          gosub SetTitleWindowValues bank14

          rem Note: Bitmap data is loaded automatically by titlescreen
          rem   kernel via includes
          rem BeginTitleScreen is called same-bank from SetupTitle (both in bank14)
          rem SetupTitle uses gosub (same-bank call, pushes 2 bytes), so return thisbank is correct
          rem SetupTitle itself returns with return thisbank to handle the cross-bank call to ChangeGameMode
          return thisbank