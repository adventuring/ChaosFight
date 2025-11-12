BeginTitleScreen
          rem ChaosFight - Source/Routines/BeginTitleScreen.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

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

          let titleParadeTimer = 0
          rem Initialize title parade state
          let titleParadeActive = 0

          rem Set background color
          COLUBK = ColGray(0)

          let temp1 = MusicChaotica
          rem Start Chaotica title music
          gosub StartMusic bank1

          gosub SetTitleWindowValues bank14
          rem Set window values for Title screen (ChaosFight only)

          rem Note: Bitmap data is loaded automatically by titlescreen
          rem   kernel via includes

          return
