;;;; .SLEEP macro for ChaosFight
;;;; Provides cycle-accurate delays
;;;; Based on Tools/batariBASIC/includes/macro.h `SLEEP`
;;;;
;;;; Upstream (dasm) definition, for reference:
;;;;
;;;;            MAC SLEEP            ;usage: SLEEP n (n>1)
;;;; .CYCLES     SET {1}
;;;;                 IF .CYCLES < 2
;;;;                     ECHO "MACRO ERROR: 'SLEEP': Duration must be > 1"
;;;;                     ERR
;;;;                 ENDIF
;;;;                 IF .CYCLES & 1
;;;;                     IFNCONST NO_ILLEGAL_OPCODES
;;;;                         nop 0
;;;;                     ELSE
;;;;                         bit VSYNC
;;;;                     ENDIF
;;;; .CYCLES             SET .CYCLES - 3
;;;;                 ENDIF
;;;;                 REPEAT .CYCLES / 2
;;;;                     nop
;;;;                 REPEND
;;;;             ENDM
;;;;
;;;; i.e. for an odd duration: a 3-cycle `nop 0` *plus* (n-3)/2 2-cycle
;;;; nops, so the total is exactly n cycles.
;;;;
;;;; This file previously emitted the `nop 0` alone for odd durations and
;;;; skipped the trailing `nop` pairs, so `.SLEEP 63` took 3 cycles instead
;;;; of 63.  That silently broke every cycle-exact delay with an odd
;;;; argument; in the titlescreen kernel it shifted the bitmap loop 60
;;;; cycles out of phase with the sprite, so only one of the six bitmap
;;;; columns was displayed (repeated by NUSIZ), instead of the 48-pixel
;;;; image.
;;;;
;;;; NOTE: .weak protection is needed because Preamble.s (which includes
;;;; this file) is included multiple times.  64tass doesn't support
;;;; .ifndef include guards, so .weak/.endweak is the standard way to
;;;; allow duplicate symbol definitions.
.weak

SLEEP .macro duration
          ;;; usage: .SLEEP n (n > 1)

.if \duration < 2
          .error "MACRO ERROR: \"SLEEP\": Duration must be > 1"
.fi

.if \duration & 1
          ;; Odd duration: 3-cycle nop plus (n-3)/2 2-cycle nops.
          ;; For n = 3 this is just the nop, which is already 3 cycles.
          nop 0
          .if \duration > 3
          .rept (\duration - 3) / 2
          nop
          .next
          .fi
.else
          ;; Even duration: n/2 2-cycle nops.
          .rept \duration / 2
          nop
          .next
.fi
.endm

.endweak
