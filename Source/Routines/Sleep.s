; Sleep macro for ChaosFight
; Provides cycle-accurate delays
; Based on Tools/batariBASIC/includes/macro.h (but actual definition is commented there)
; Note: This file is included once in Preamble.bas before MultiSpriteSuperChip.s
; Workaround: DASM can’t use macro-local variables (.CYCLES) in REPEAT expressions,
; so we calculate the repeat count directly from the macro argument

          MAC SLEEP            ;usage: SLEEP n (n>1)
          IF {1} < 2
              ECHO "MACRO ERROR: "SLEEP": Duration must be > 1"
              ERR
          ENDIF
          
          IF {1} & 1
              IFNCONST NO_ILLEGAL_OPCODES
                  nop 0
              ELSE
                  bit VSYNC
              ENDIF
              IF {1} >= 3
                  REPEAT ({1} - 3) / 2
                      nop
                  REPEND
              ENDIF
          ELSE
              REPEAT {1} / 2
                  nop
              REPEND
          ENDIF
          ENDM
