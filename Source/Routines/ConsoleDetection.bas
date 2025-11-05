          rem ChaosFight - Source/Routines/ConsoleDetection.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem ==========================================================
          rem CONSOLE DETECTION
          rem ==========================================================
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
          rem Assume 2600 console initially
          let systemFlags = systemFlags & ClearSystemFlag7800
          let console7800Detected = 0
          
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
          let systemFlags = systemFlags | SystemFlag7800
          let console7800Detected = 1
          return
          
Is2600
          rem 2600 console detected
          let systemFlags = systemFlags & ClearSystemFlag7800
          let console7800Detected = 0
          return
          
          rem ==========================================================
          rem CONSOLE FEATURE DETECTION
          rem ==========================================================
          rem Check for console-specific features after detection
          
CheckConsoleFeatures
          rem Check if running on 7800
          if !console7800Detected then Done7800Features
          
          rem 7800-specific features
          rem Note: 7800 pause button handling is implemented in
          rem   ControllerDetection.bas (Check7800Pause) and called
          rem   from ConsoleHandling.bas during the game loop
          rem Note: Controller detection works for both 2600 and 7800
          rem   via ControllerDetection.bas (DetectControllers)
          rem   No console-specific initialization needed
          goto ConsoleFeaturesDone
          
Done7800Features
          rem 2600-specific features
          rem Note: Controller detection works for both 2600 and 7800
          rem   via ControllerDetection.bas (DetectControllers)
          rem   No console-specific initialization needed
          
ConsoleFeaturesDone
          return
