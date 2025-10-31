          rem ChaosFight - Source/Routines/ConsoleDetection.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem CONSOLE DETECTION
          rem =================================================================
          rem Detects whether running on Atari 2600 or 7800 console
          rem Based on DetectConsole.s assembly implementation
          
          rem DETECTION LOGIC:
          rem   if $D0 contains $2C and $D1 contains $A9 then
          rem       system = 7800           // game was loaded from Harmony menu on a 7800
          rem   else if both contain $00 then
          rem       system = ZP RAM $80     // game was flashed to Harmony/Melody so CDFJ
          rem                               // driver checked $D0 and $D1 for us and saved
          rem                               // results in $80
          rem   else
          rem       system = 2600           // game was loaded from Harmony menu on a 2600
          rem =================================================================
          
          rem Main console detection routine
ConsoleDetHW
          rem Assume 2600 console initially
          SystemFlags = SystemFlags & ClearSystemFlag7800
          Console7800Detected = 0
          
          rem Check $D0 value
          temp1 = $D0
          if temp1 = 0 then goto CheckFlashed
          
          rem Check if $D0 = $2C (7800 indicator)
          if temp1 <> ConsoleDetectD0 then goto Is2600
          
          rem Check $D1 value for 7800 confirmation
          temp1 = $D1
          if temp1 <> ConsoleDetectD1 then goto Is2600
          
          rem 7800 detected: $D0=$2C and $D1=$A9
          goto Is7800
          
CheckFlashed
          rem Check if $D1 is also $00 (flashed game)
          temp1 = $D1
          if temp1 <> 0 then goto Is2600
          
          rem Both $D0 and $D1 are $00 - check $80 for CDFJ driver result
          temp1 = $80
          if temp1 = 0 then goto Is2600
          
          rem CDFJ driver detected 7800
          goto Is7800
          
Is7800
          rem 7800 console detected
          SystemFlags = SystemFlags | SystemFlag7800
          Console7800Detected = 1
          return
          
Is2600
          rem 2600 console detected
          SystemFlags = SystemFlags & ClearSystemFlag7800
          Console7800Detected = 0
          return
          
          rem =================================================================
          rem CONSOLE FEATURE DETECTION
          rem =================================================================
          rem Check for console-specific features after detection
          
CheckConsoleFeatures
          rem Check if running on 7800
          if !Console7800Detected then goto Skip7800Features
          
          rem 7800-specific features
          rem TODO: Implement 7800-specific pause button handling
          rem TODO: Implement 7800-specific controller detection
          goto ConsoleFeaturesDone
          
Skip7800Features
          rem 2600-specific features
          rem TODO: Implement 2600-specific optimizations
          
ConsoleFeaturesDone
          return
