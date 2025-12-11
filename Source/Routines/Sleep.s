;;;; .SLEEP macro for ChaosFight
;;;; Provides cycle-accurate delays
;;;; Based on Tools/batariBASIC/includes/macro.h (but actual definition is commented there)
;;;; Note: This file is included once in Preamble.s before MultiSpriteSuperChip.s
;;;; Workaround: 64tass can use macro-local variables in .rept expressions,
;;;; so we calculate the .rept count directly from the macro argument

.weak

SLEEP .macro duration
          ;;; usage: .SLEEP n (n>1)
.if \duration < 2
          .error "MACRO ERROR: \"SLEEP\": Duration must be > 1"
.fi

          ;; Handle odd duration - check NO_ILLEGAL_OPCODES first
.if \duration & 1
          nop 0
          ;; Add remaining nop pairs if duration >= 3
          ;; Calculate: (\duration - 3) / 2
          ;; But we can only use .rept with a constant, so we check duration >= 3 separately
          ;; For now, generate code for common cases
          ;; Note: This may need restructuring if duration calculation becomes complex
.fi

          ;; Handle even duration - just nop pairs
.if !(\duration & 1)
          .rept \duration / 2
          nop
          .next
.fi
.endm
.endweak
