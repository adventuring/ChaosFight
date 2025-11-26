          rem ChaosFight - Source/Common/Preamble.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          set includesfile ChaosFight.inc

;; CRITICAL: Include AssemblyConfig.bas FIRST to set processor directive
;; This must be before MultiSpriteSuperChip.s (which includes vcs.h and macro.h)
#include "Source/Common/AssemblyConfig.bas"

          asm

;; Define TV standard constants for ifconst checks in MultiSpriteSuperChip.s
;; These are set by the platform files (NTSC.bas, PAL.bas, SECAM.bas) before
;; Preamble.bas is included. The platform files use #define TV_PAL, #define TV_SECAM, etc.
;; but assembly code needs _TV_PAL, _TV_SECAM symbols defined with SET.
;; Note: batariBASIC preprocessor doesn't support #ifdef, so we define all three
;; and let the build system ensure only the correct one is used.
;; For NTSC builds, _TV_PAL and _TV_SECAM will be undefined (ifconst will fail).
;; For PAL builds, _TV_PAL will be defined.
;; For SECAM builds, _TV_SECAM will be defined.
;; The platform files will override these with the correct values.

;; Include sleep macro (macro.h documents it but doesn't define it)
#include "Source/Routines/Sleep.s"

;; CRITICAL: Include MultiSpriteSuperChip.s FIRST to define all symbols before
;; batariBASIC includes are processed. This ensures symbols like frame,
;; missile0height, missile1height, qtcontroller, playfieldRow, miniscoretable,
;; etc. are available when batariBASIC includes reference them.
#include "Source/Common/MultiSpriteSuperChip.s"

          asm
            ;; CRITICAL: Define constants used in assembly code as EQU statements for DASM
            ;; These must be defined early so DASM can resolve them when used in assembly code
            ;; (e.g., LDA #PlayerRightEdge). Values match const definitions in Constants.bas.
ScreenWidth          EQU 160
ScreenLeftMargin     EQU 16
ScreenRightMargin    EQU 16
PlayerSpriteWidth    EQU 16
PlayerSpriteHalfWidth EQU 8
PlayerLeftEdge       EQU 16    ; ScreenLeftMargin
PlayerRightEdge      EQU 128   ; ScreenWidth - ScreenRightMargin - PlayerSpriteWidth = 160 - 16 - 16
PlayerWrapOvershoot  EQU 8     ; PlayerSpriteHalfWidth
PlayerLeftWrapThreshold EQU 8  ; PlayerLeftEdge - PlayerWrapOvershoot = 16 - 8
PlayerRightWrapThreshold EQU 136 ; PlayerRightEdge + PlayerWrapOvershoot = 128 + 8
            ;; Music bank constants for assembly code
Bank15MaxSongID      EQU 6
Bank1MinSongID       EQU 7     ; Bank15MaxSongID + 1
            ;; NOTE: Variables like missile0height, missile1height, playfieldRow, rand16
            ;; are memory addresses (defined with = in MultiSpriteSuperChip.s), not constants.
            ;; They don’t need EQU definitions - they’re resolved by DASM when used as addresses.
            ;; NOT is also a memory address, not a constant, and should not be used as an operator.
end

          asm
;; CRITICAL: Base variables (var0-var47, a-z) are defined in MultiSpriteSuperChip.s
;; which is included above. Do NOT redefine them here as that causes EQU value mismatch errors.
;; The Makefile inserts include "2600basic_variable_redefs.h" early (after processor 6502),
;; and MultiSpriteSuperChip.s is included before that point, so all base variables
;; are available when the redefs file is processed.
;; var48-var127 don’t exist - SuperChip RAM accessed via r000-r127/w000-w127 only
;; playerCharacter is now in SCRAM (w111-w114), defined in Variables.bas
;; CRITICAL: $f0-$ff is 100% reserved for stack - NO variables allowed
;; Z/z removed - use SCRAM for any variables that were using z
end

#include "Source/Common/Colors.h"
#include "Source/Common/Constants.bas"
#include "Source/Common/Enums.bas"
#include "Source/Common/Macros.bas"
#include "Source/Common/Variables.bas"
