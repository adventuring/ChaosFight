;;; ChaosFight - Source/Common/Preamble.s
;;; Copyright © 2025 Bruce-Robert Pocock.

;; CRITICAL: Include AssemblyConfig.s FIRST to set processor directive
;; This must be before MultiSpriteSuperChip.s (which includes vcs.h and macro.h)
.include "Source/Common/AssemblyConfig.s"


;; Define TV standard constants for .if  checks in MultiSpriteSuperChip.s
;; These are set by the platform files (NTSC.s, PAL.s, SECAM.s) before
;; Preamble.s is included. The platform files define TVStandard constants.
;; but assembly code needs (TVStandard == 1), (TVStandard == 2) symbols defined with SET.
;; Note: batariBASIC preprocessor doesn’t support #ifdef, so we define all three
;; and let the build system ensure only the correct one is used.
;; For NTSC builds, (TVStandard == 1) and (TVStandard == 2) will be undefined (.if  will fail).
;; For PAL builds, (TVStandard == 1) will be defined.
;; For SECAM builds, (TVStandard == 2) will be defined.
;; The platform files will override these with the correct values.

;; Include .SLEEP macro (macro.h documents it but doesn’t define it)
.include "Source/Routines/Sleep.s"

;; CRITICAL: Include MultiSpriteSuperChip.s FIRST to define all symbols before
;; batariBASIC includes are processed. This ensures symbols like frame,
;; missile0height, missile1height, qtcontroller, playfieldRow, miniscoretable,
;; etc. are available when batariBASIC includes reference them.
.include "Source/Common/MultiSpriteSuperChip.s"

;; CRITICAL: Define constants used in assembly code as = statements for 64tass
;; These must be defined early so 64tass can resolve them when used in assembly code
;; (e.g., lda #PlayerRightEdge). Values match const definitions in Constants.s.
ScreenWidth = 160
ScreenLeftMargin = 16
ScreenRightMargin = 16
PlayerSpriteWidth = 16
PlayerSpriteHalfWidth = 8
PlayerLeftEdge = 16    ;; ScreenLeftMargin
PlayerRightEdge = 128  ;; ScreenWidth - ScreenRightMargin - PlayerSpriteWidth = 160 - 16 - 16
PlayerWrapOvershoot = 8     ;; PlayerSpriteHalfWidth
PlayerLeftWrapThreshold = 8  ;; PlayerLeftEdge - PlayerWrapOvershoot = 16 - 8
PlayerRightWrapThreshold = 136 ;; PlayerRightEdge + PlayerWrapOvershoot = 128 + 8
;; Music bank constants for assembly code
Bank14MaxSongID = 6
Bank0MinSongID = 7     ;; Bank14MaxSongID + 1
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

.include "Source/Common/Colors.h"
.include "Source/Common/Constants.s"
.include "Source/Common/Enums.s"
.include "Source/Common/Macros.s"
.include "Source/Common/Variables.s"

;;; Bank switching labels - defined in Banks.s after Bank1.s is included
;;; Note: BS_return and BS_jsr are sequential - BS_jsr comes after BS_return
;;; Forward declarations removed - will be defined in Banks.s as Bank0BS.BS_return and Bank0BS.BS_jsr
;;; Global labels BS_return and BS_return reference Bank 0 block; all banks have identical addresses
