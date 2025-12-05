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
          rem Called Routines: StartMusic (bank15) - starts title music
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
          rem OPTIMIZATION: Inlined to save call overhead (only used once)
          let titlescreenWindow1 = 0   ; AtariAge logo hidden
          let titlescreenWindow2 = 0   ; AtariAgeText hidden
          let titlescreenWindow3 = 42  ; ChaosFight visible
          let titlescreenWindow4 = 0   ; Interworldly hidden

          rem Note: Bitmap data is loaded automatically by titlescreen
          rem   kernel via includes
          rem BeginTitleScreen is called cross-bank from SetupTitle
          rem (gosub BeginTitleScreen bank14 forces BS_jsr even though same bank)
          rem so it must return with return otherbank to match
          return otherbank
