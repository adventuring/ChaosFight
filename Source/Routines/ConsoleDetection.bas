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
          asm
ConsoleDetHW
end
          rem Detect whether running on Atari 2600 or 7800 console
          rem
          rem Input: $D0, $D1 (hardware registers) = console detection
          rem values
          rem        $80 (zero-page RAM) = CDFJ driver detection result
          rem        (if flashed)
          rem
          rem Output: systemFlags initialized to 0, then updated with
          rem SystemFlag7800 if 7800 detected
          rem
          rem Mutates: systemFlags (initialized to 0, then SystemFlag7800
          rem set or cleared), temp1 (used for hardware register reads)
          rem
          rem Called Routines: None (reads hardware registers directly)
          rem
          rem Constraints: Must be colocated with CheckFlashed, Is7800,
          rem Is2600 (all called via goto)
          rem              MUST run before any code modifies $D0/$D1
          rem              registers
          rem              Entry point for console detection (called
          rem              from ColdStart)
          let systemFlags = 0
          rem Initialize systemFlags to 0 (assume 2600 console initially)
          rem No need to read prior value since it contains random garbage at startup

          rem Check $D0 value
          asm
          lda $D0
          sta temp1
end
          if temp1 = 0 then goto CheckFlashed

          rem Check if $D0 = $2C (7800 indicator)

          if temp1 = ConsoleDetectD0 then goto CheckD1
          goto Is2600

CheckD1
          rem Check $D1 value for 7800 confirmation
          asm
          lda $D1
          sta temp1
end
          if temp1 = ConsoleDetectD1 then goto Is7800
          goto Is2600
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

          rem fall through to Is7800
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
          let systemFlags = SystemFlag7800
          goto ConsoleDetected

Is2600
          rem 2600 console detected
ConsoleDetected