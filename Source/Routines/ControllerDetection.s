; ChaosFight - Source/Routines/ControllerDetection.s
;; Copyright © 2025 Bruce-Robert Pocock.

; Detects whether running on Atari 2600 or 7800 console.
; Based on DetectConsole.s assembly implementation.

ConsoleDetHW .proc
    ; Initialize console7800Detected to 0 (assume 2600 initially)
    lda # 0
    sta console7800Detected

    ; Read $D0
    lda $d0
    sta temp1
    lda temp1
    beq CheckD1                     ; If zero, check $D1

CheckD0For7800:
    ; Check if $D0 = $2C (7800 indicator)
    cmp # ConsoleDetectD0
    bne Not7800ConsoleD0
    jmp CheckD1

Not7800ConsoleD0:
    jmp Is2600Console

CheckD1 .proc
    ; Check $D1 for 7800 confirmation
    lda $D1
    sta temp1
    cmp # ConsoleDetectD1
    bne Not7800ConsoleD1
    jmp Is7800Console

Not7800ConsoleD1:
    jmp Is2600Console

CheckFlashed .proc
    ; Check if game was flashed to Harmony/Melody (both $D0 and $D1 are $00)
    lda $D1
    sta temp1
    ; If temp1 is non-zero, jmp Is2600Console
    lda temp1
    beq CheckCDFJDriver
    jmp Is2600Console

CheckCDFJDriver:
    ; Both $D0 and $D1 are $00 - check $80 for CDFJ driver result
    lda console7800Detected
    sta temp1
    lda temp1
    cmp # $80
    beq CDFJDriverDetected7800
    cmp # $00
    beq CDFJDriverDetected2600
    jmp Is2600Console

CDFJDriverDetected2600:
    jmp Is2600Console

CDFJDriverDetected7800:
    ; fall through to Is7800Console
    jmp Is7800Console

    .pend

Is7800Console .proc
    ; 7800 console detected
    lda # $80
    sta console7800Detected          ; Set $80 to $80 for 7800 console
    jmp ConsoleDetected

    .pend

Is2600Console .proc
    ; 2600 console detected
    lda # $00
    sta console7800Detected          ; Set $80 to $00 for 2600 console
    jmp ConsoleDetected

    .pend

ConsoleDetected: