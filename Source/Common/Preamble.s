;;; ChaosFight - Source/Common/Preamble.s
;;; Copyright © 2025 Bruce-Robert Pocock.

;; CRITICAL: Include AssemblyConfig.s FIRST to set processor directive
;; This must be before MultiSpriteSuperChip.s (which includes vcs.h and macro.h)
.include "Source/Common/AssemblyConfig.s"


;; Define TV standard constants for .if  checks in MultiSpriteSuperChip.s
;; These are set by the platform files (NTSC.s, PAL.s, SECAM.s) before
;; Preamble.s is included. The platform files define TVStandard constants.
;; but assembly code needs (TVStandard == PAL), (TVStandard == SECAM) symbols defined with SET.
;; Note: batariBASIC preprocessor doesn’t support #ifdef, so we define all three
;; and let the build system ensure only the correct one is used.
;; For NTSC builds, (TVStandard == PAL) and (TVStandard == SECAM) will be undefined (.if  will fail).
;; For PAL builds, (TVStandard == PAL) will be defined.
;; For SECAM builds, (TVStandard == SECAM) will be defined.
;; The platform files will override these with the correct values.

;; Include .SLEEP macro (macro.h documents it but doesn’t define it)
.include "Source/Routines/Sleep.s"

;; CRITICAL: Include MultiSpriteSuperChip.s FIRST to define all symbols before
;; batariBASIC includes are processed. This ensures symbols like frame,
;; missile0height, missile1height, qtcontroller, playfieldRow, miniscoretable,
;; etc. are available when batariBASIC includes reference them.
.include "Source/Common/MultiSpriteSuperChip.s"

;; CRITICAL: Constants are defined in Constants.s
;; These constants are available here because Constants.s is included below
;; (e.g., lda #PlayerRightEdge)
;; NOTE: Variables like missile0height, missile1height, playfieldRow, rand16
;; are memory addresses (defined with = in MultiSpriteSuperChip.s), not constants

;; They don't need = definitions - they're resolved by 64tass when used as addresses.
;; NOT is also a memory address, not a constant, and should not be used as an operator.

;; CRITICAL: Base variables (var0-var47, a-z) are defined in MultiSpriteSuperChip.s
;; which is included above. Do NOT redefine them here as that causes = value mismatch errors.
;; var48-var127 don't exist - SuperChip RAM accessed via r000-r127/w000-w127 only
;; playerCharacter is in SCRAM (w111-w114), defined in Variables.s
;; CRITICAL: $f0-$ff is 100% reserved for stack - NO variables allowed
;; Z/z removed - use SCRAM for any variables that were using z

.include "Source/Common/Colors.s"
.include "Source/Common/Constants.s"
.include "Source/Common/Enums.s"
.include "Source/Common/Macros.s"
.include "Source/Common/Variables.s"

;;; Bank switching labels - defined in Banks.s after Bank1.s is included
;;; Note: BS_return and BS_jsr are sequential - BS_jsr comes after BS_return
;;; Forward declarations removed - will be defined in Banks.s as Bank0BS.BS_return and Bank0BS.BS_jsr
;;; Global labels BS_return and BS_jsr reference Bank 0 block; all banks have identical addresses
