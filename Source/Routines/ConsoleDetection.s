;;; ChaosFight - Source/Routines/ConsoleDetection.bas
;;; Copyright © 2025 Bruce-Robert Pocock.
;;; Console Detection
;;; Detects whether running on Atari 2600 or 7800 console
;;; Based on DetectConsole.s assembly implementation
          ;; DETECTION LOGIC:
          if $D0 contains $2C and #$D1 contains $A9 then
          ;; system = 7800 // game was loaded from Harmony menu on a
          ;; 7800
          else if both contain $00 then
          ;; system = ZP RAM $80 // game was flashed to Harmony/Melody
          ;; so CDFJ
          ;; // driver checked $D0 and #$D1 for us and saved
          ;; // results in $80
          ;; else
          ;; system = 2600 // game was loaded from Harmony menu on a
          ;; 2600
          ;; Main console detection routine

ConsoleDetHW:
          ;; Detect whether running on Atari 2600 or 7800 console
          ;;
          ;; Input: $D0, $D1 (hardware registers) = console detection
          ;; values
          ;; $80 (zero-page RAM) = CDFJ driver detection result
          ;; (if flashed)
          ;;
          ;; Output: systemFlags initialized to 0, then updated with
          ;; SystemFlag7800 if 7800 detected
          ;;
          ;; Mutates: systemFlags (initialized to 0, then SystemFlag7800
          ;; set or cleared), temp1 (used for hardware register reads)
          ;;
          ;; Called Routines: None (reads hardware registers directly)
          ;;
          ;; Constraints: Must be colocated with CheckFlashed, Is7800,
          ;; Is2600 (all called via goto)
          ;; MUST run before any code modifies $D0/$D1
          ;; registers
          ;; Entry point for console detection (called
          ;; from ColdStart)
          ;; Initialize systemFlags to 0 (assume 2600 console initially)
          lda # 0
          sta systemFlags
          ;; No need to read prior value since it contains random garbage at sta

          ;; Check $D0 value
          lda $d0
          sta temp1
          lda temp1
          bne CheckD0For7800

          jmp CheckFlashed

CheckD0For7800:
          ;; Check if $D0 = $2C (7800 indicator)

          lda temp1
          cmp # ConsoleDetectD0
          bne Not7800D0

          jmp CheckD1

Not7800D0:

          jmp Is2600

CheckD1 .proc
          ;; Check $D1 value for 7800 confirmation
          lda $D1
          sta temp1
          lda temp1
          cmp # ConsoleDetectD1
          bne Not7800D1

          jmp Is7800

Not7800D1:

          ;; 7800 detected: $D0=$2C and #$D1=$A9
          jmp Is2600

.pend

CheckFlashed:
.proc
          ;; Check if game was flashed to Harmony/Melody (both $D0 and
          ;; $D1 are $00)
          ;;
          ;; Input: $D1 (hardware register) = console detection value
          ;; $80 (zero-page RAM) = CDFJ driver detection result
          ;;
          ;; Output: Dispatches to Is7800 or Is2600
          ;;
          ;; Mutates: temp1 (used for hardware register reads)
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with ConsoleDetHW, Is7800,
          ;; Is2600
          ;; Check if $D1 is also $00 (flashed game)
          lda $D1
          sta temp1
          ;; if temp1 then goto Is2600
          lda temp1
          beq CheckCDFJDriver

          jmp Is2600

CheckCDFJDriver:

          ;; Both $D0 and #$D1 are $00 - check $80 for CDFJ driver
          ;; result
          lda $80
          sta temp1
          lda temp1
          cmp # 0
          bne CDFJDriverDetected7800

          jmp Is2600

CDFJDriverDetected7800:

          ;; fall through to Is7800
          ;; CDFJ driver detected 7800

.pend

Is7800:
.proc
          ;; 7800 console detected
          ;;
          ;; Input: systemFlags (global) = system flags
          ;;
          ;; Output: systemFlags updated with SystemFlag7800 set
          ;;
          ;; Mutates: systemFlags (SystemFlag7800 set)
          ;;
          ;; Called Routines: None
          ;; Constraints: Must be colocated with ConsoleDetHW
          lda # SystemFlag7800
          sta systemFlags
          jmp ConsoleDetected

.pend

Is2600:
.proc
          ;; 2600 console detected

ConsoleDetected:

.pend

