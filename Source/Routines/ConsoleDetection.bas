          rem ChaosFight - Source/Routines/ConsoleDetection.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Console Detection
          rem Detects whether running on Atari 2600 or 7800 console
          rem Based on DetectConsole.s assembly implementation
          rem DETECTION LOGIC:
          rem   if $D0 contains $2C and $D1 contains $A9 then
          rem system = 7800 // game was loaded from Harmony menu on a
          rem   7800
          rem   else if both contain $00 then
          rem system = ZP RAM $80 // game was flashed to Harmony/Melody
          rem   so CDFJ
          rem // driver checked $D0 and $D1 for us and saved
          rem                               // results in $80
          rem   else
          rem system = 2600 // game was loaded from Harmony menu on a
          rem   2600
          rem Main console detection routine

ConsoleDetHW
          rem Detect whether running on Atari 2600 or 7800 console
          rem
          rem Input: $D0, $D1 (hardware registers) = console detection
          rem values
          rem        $80 (zero-page RAM) = CDFJ driver detection result
          rem        (if flashed)
          rem        systemFlags (global) = system flags
          rem
          rem Output: systemFlags updated with SystemFlag7800 if 7800
          rem detected
          rem
          rem Mutates: systemFlags (SystemFlag7800 set or cleared),
          rem temp1 (used for hardware register reads)
          rem
          rem Called Routines: None (reads hardware registers directly)
          rem
          rem Constraints: Must be colocated with CheckFlashed, Is7800,
          rem Is2600 (all called via goto)
          rem              MUST run before any code modifies $D0/$D1
          rem              registers
          rem              Entry point for console detection (called
          rem              from ColdStart)
          let systemFlags = systemFlags & ClearSystemFlag7800
          rem Assume 2600 console initially

          rem Check $D0 value
          asm
          lda $D0
          sta temp1
end
          if temp1 = 0 then goto CheckFlashed

          rem Check if $D0 = $2C (7800 indicator)

          if temp1 <> ConsoleDetectD0 then goto Is2600

          rem Check $D1 value for 7800 confirmation
          asm
          lda $D1
          sta temp1
end
          if temp1 <> ConsoleDetectD1 then goto Is2600

          goto Is7800
          rem 7800 detected: $D0=$2C and $D1=$A9

CheckFlashed
          rem Check if game was flashed to Harmony/Melody (both $D0 and
          rem $D1 are $00)
          rem
          rem Input: $D1 (hardware register) = console detection value
          rem        $80 (zero-page RAM) = CDFJ driver detection result
          rem
          rem Output: Dispatches to Is7800 or Is2600
          rem
          rem Mutates: temp1 (used for hardware register reads)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with ConsoleDetHW, Is7800,
          rem Is2600
          rem Check if $D1 is also $00 (flashed game)
          asm
          lda $D1
          sta temp1
end
          if temp1 then goto Is2600

          rem Both $D0 and $D1 are $00 - check $80 for CDFJ driver
          rem   result
          asm
          lda $80
          sta temp1
end
          if temp1 = 0 then goto Is2600

          goto Is7800
          rem CDFJ driver detected 7800

Is7800
          rem 7800 console detected
          rem
          rem Input: systemFlags (global) = system flags
          rem
          rem Output: systemFlags updated with SystemFlag7800 set
          rem
          rem Mutates: systemFlags (SystemFlag7800 set)
          rem
          rem Called Routines: None
          rem Constraints: Must be colocated with ConsoleDetHW
          let systemFlags = systemFlags | SystemFlag7800
          return

Is2600
          rem 2600 console detected
          rem
          rem Input: systemFlags (global) = system flags
          rem
          rem Output: systemFlags updated with SystemFlag7800 cleared
          rem
          rem Mutates: systemFlags (SystemFlag7800 cleared)
          rem
          rem Called Routines: None
          rem Constraints: Must be colocated with ConsoleDetHW
          let systemFlags = systemFlags & ClearSystemFlag7800
          return

          rem
          rem Console Feature Detection
          rem Entry point after base detection; applies console-specific features.

CheckConsoleFeatures
          rem
          rem Input: systemFlags (global) = system flags (SystemFlag7800
          rem indicates 7800)
          rem
          rem Output: None (no console-specific initialization needed)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with Done7800Features,
          rem ConsoleFeaturesDone
          rem Check if running on 7800 (bit 7 of systemFlags)
          if (systemFlags & SystemFlag7800) = 0 then Done7800Features

          rem 7800-specific features
          rem Note: 7800 pause button handling is implemented in
          rem   ControllerDetection.bas (Check7800Pause) and called
          rem   from ConsoleHandling.bas during the game loop
          rem Note: Controller detection works for both 2600 and 7800
          rem   via ControllerDetection.bas (DetectPads)
          goto ConsoleFeaturesDone
          rem   No console-specific initialization needed

Done7800Features
ConsoleFeaturesDone
          rem 2600-specific features (label only, no execution)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with CheckConsoleFeatures
          rem 2600-specific features
          rem Note: Controller detection works for both 2600 and 7800
          rem   via ControllerDetection.bas (DetectPads)
          rem   No console-specific initialization needed
          return
          rem Console features check complete (label only, no execution)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with CheckConsoleFeatures
