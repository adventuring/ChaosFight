          rem ChaosFight - Source/Routines/ConsoleDetection.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem Console Detection
          rem
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
          rem ==========================================================
          
          rem Main console detection routine
ConsoleDetHW
          rem Detect whether running on Atari 2600 or 7800 console
          rem Input: $D0, $D1 (hardware registers) = console detection values
          rem        $80 (zero-page RAM) = CDFJ driver detection result (if flashed)
          rem        systemFlags (global) = system flags
          rem Output: systemFlags updated with SystemFlag7800 if 7800 detected
          rem Mutates: systemFlags (SystemFlag7800 set or cleared), temp1 (used for hardware register reads)
          rem Called Routines: None (reads hardware registers directly)
          rem Constraints: Must be colocated with CheckFlashed, Is7800, Is2600 (all called via goto)
          rem              MUST run before any code modifies $D0/$D1 registers
          rem              Entry point for console detection (called from ColdStart)
          rem Assume 2600 console initially
          let systemFlags = systemFlags & ClearSystemFlag7800
          
          rem Check $D0 value
          temp1 = $D0
          if temp1 = 0 then CheckFlashed
          
          rem Check if $D0 = $2C (7800 indicator)
          if !(temp1 = ConsoleDetectD0) then goto Is2600
          
          rem Check $D1 value for 7800 confirmation
          temp1 = $D1
          if !(temp1 = ConsoleDetectD1) then goto Is2600
          
          rem 7800 detected: $D0=$2C and $D1=$A9
          goto Is7800
          
CheckFlashed
          rem Check if game was flashed to Harmony/Melody (both $D0 and $D1 are $00)
          rem Input: $D1 (hardware register) = console detection value
          rem        $80 (zero-page RAM) = CDFJ driver detection result
          rem Output: Dispatches to Is7800 or Is2600
          rem Mutates: temp1 (used for hardware register reads)
          rem Called Routines: None
          rem Constraints: Must be colocated with ConsoleDetHW, Is7800, Is2600
          rem Check if $D1 is also $00 (flashed game)
          temp1 = $D1
          if temp1 then Is2600
          
          rem Both $D0 and $D1 are $00 - check $80 for CDFJ driver
          rem   result
          temp1 = $80
          if temp1 = 0 then Is2600
          
          rem CDFJ driver detected 7800
          goto Is7800
          
Is7800
          rem 7800 console detected
          rem Input: systemFlags (global) = system flags
          rem Output: systemFlags updated with SystemFlag7800 set
          rem Mutates: systemFlags (SystemFlag7800 set)
          rem Called Routines: None
          rem Constraints: Must be colocated with ConsoleDetHW
          let systemFlags = systemFlags | SystemFlag7800
          return
          
Is2600
          rem 2600 console detected
          rem Input: systemFlags (global) = system flags
          rem Output: systemFlags updated with SystemFlag7800 cleared
          rem Mutates: systemFlags (SystemFlag7800 cleared)
          rem Called Routines: None
          rem Constraints: Must be colocated with ConsoleDetHW
          let systemFlags = systemFlags & ClearSystemFlag7800
          return
          
          rem Console Feature Detection
          rem
          rem Check for console-specific features after detection
          
CheckConsoleFeatures
          rem Check for console-specific features after detection
          rem Input: systemFlags (global) = system flags (SystemFlag7800 indicates 7800)
          rem Output: None (no console-specific initialization needed)
          rem Mutates: None
          rem Called Routines: None
          rem Constraints: Must be colocated with Done7800Features, ConsoleFeaturesDone
          rem Check if running on 7800 (bit 7 of systemFlags)
          if !(systemFlags & SystemFlag7800) then Done7800Features
          
          rem 7800-specific features
          rem Note: 7800 pause button handling is implemented in
          rem   ControllerDetection.bas (Check7800Pause) and called
          rem   from ConsoleHandling.bas during the game loop
          rem Note: Controller detection works for both 2600 and 7800
          rem   via ControllerDetection.bas (DetectControllers)
          rem   No console-specific initialization needed
          goto ConsoleFeaturesDone
          
Done7800Features
          rem 2600-specific features (label only, no execution)
          rem Input: None (label only, no execution)
          rem Output: None (label only)
          rem Mutates: None
          rem Called Routines: None
          rem Constraints: Must be colocated with CheckConsoleFeatures
          rem 2600-specific features
          rem Note: Controller detection works for both 2600 and 7800
          rem   via ControllerDetection.bas (DetectControllers)
          rem   No console-specific initialization needed
          
ConsoleFeaturesDone
          rem Console features check complete (label only, no execution)
          rem Input: None (label only, no execution)
          rem Output: None (label only)
          rem Mutates: None
          rem Called Routines: None
          rem Constraints: Must be colocated with CheckConsoleFeatures
          return
