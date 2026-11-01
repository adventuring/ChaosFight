;;; ChaosFight - Source/Routines/CharacterSelectEntry.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

CharacterSelectEntry .block
          ;; Initializes character select screen sta

          ;; Notes: PlayerLockedHelpers.bas resides in Bank 6
          ;;
          ;; Input: None (entry point)
          ;;
          ;; Output: playerCharacter[] initialized, playerLocked
          ;; initialized, animation state initialized,
          ;; COLUBK set, Quadtari detection called
          ;;
          ;; Mutates: playerCharacter[0-3] (P1=RandomCharacter, P2=RandomCharacter,
          ;; P3/P4=NoCharacter), playerLocked (P2/P3/P4 locked),
          ;; characterSelectAnimationTimer,
          ;; characterSelectAnimationState, characterSelectCharacterIndex,
          ;; characterSelectAnimationFrame, COLUBK (TIA register)
          ;;
          ;; Called Routines: CharacterSelectDetectQuadtari - accesses controller
          ;; detection sta

          ;;
          ;; Constraints: Entry point for character select screen
          ;; initialization
          ;; Per-frame loop is handled by CharacterSelectInputEntry
          ;; (in CharacterSelectMain.bas, called from MainLoop)
          ;; Player 1: RandomCharacter (not locked)
          ;; Player 2: RandomCharacter (locked)
          lda # 0
          tax
          lda # RandomCharacter
          sta playerCharacter,x
          ;; Player 3: NoCharacter (locked)
          lda # 1
          tax
          lda rand16_R
           and #$0F
           sta playerCharacter,x
          ;; Player 4: NoCharacter (locked)
          lda # 2
          tax
          lda # NoCharacter
          sta playerCharacter,x
          ;; Initialize playerLocked (bit-packed)
          lda # 3
          tax
          lda # NoCharacter
          sta playerCharacter,x
          ;; Lock Player 2 (RandomCharacter)
          lda # 0
          sta playerLocked
          ;; Lock Player 3 (NoCharacter)
          ;; Set temp1 = 1
          lda # 1
          sta temp1
          ;; Set temp2 = PlayerLockedNormal
          lda # PlayerLockedNormal
          sta temp2
          ;; Cross-bank call to SetPlayerLocked in bank 5
          ;; Return address: ENCODED with caller bank 5 ($50) for BS_return to decode
          lda # ((>(AfterSetPlayerLockedP3-1)) & $0f) | $50  ;;; Encode bank 5 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterSetPlayerLockedP3 hi (encoded)]
          lda # <(AfterSetPlayerLockedP3-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterSetPlayerLockedP3 hi (encoded)] [SP+0: AfterSetPlayerLockedP3 lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(SetPlayerLocked-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterSetPlayerLockedP3 hi (encoded)] [SP+1: AfterSetPlayerLockedP3 lo] [SP+0: SetPlayerLocked hi (raw)]
          lda # <(SetPlayerLocked-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterSetPlayerLockedP3 hi (encoded)] [SP+2: AfterSetPlayerLockedP3 lo] [SP+1: SetPlayerLocked hi (raw)] [SP+0: SetPlayerLocked lo]
          ldx # 5
          jmp BS_jsr
AfterSetPlayerLockedP3:

          ;; Lock Player 4 (NoCharacter)
          ;; Set temp1 = 2
          lda # 2
          sta temp1
          ;; Set temp2 = PlayerLockedNormal
          lda # PlayerLockedNormal
          sta temp2
          ;; Cross-bank call to SetPlayerLocked in bank 5
          ;; Return address: ENCODED with caller bank 5 ($50) for BS_return to decode
          lda # ((>(AfterSetPlayerLockedP4-1)) & $0f) | $50  ;;; Encode bank 5 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterSetPlayerLockedP4 hi (encoded)]
          lda # <(AfterSetPlayerLockedP4-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterSetPlayerLockedP4 hi (encoded)] [SP+0: AfterSetPlayerLockedP4 lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(SetPlayerLocked-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterSetPlayerLockedP4 hi (encoded)] [SP+1: AfterSetPlayerLockedP4 lo] [SP+0: SetPlayerLocked hi (raw)]
          lda # <(SetPlayerLocked-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterSetPlayerLockedP4 hi (encoded)] [SP+2: AfterSetPlayerLockedP4 lo] [SP+1: SetPlayerLocked hi (raw)] [SP+0: SetPlayerLocked lo]
          ldx # 5
          jmp BS_jsr
AfterSetPlayerLockedP4:

          ;; NOTE: Do NOT clear controllerStatus flags here - monotonic
          ;; Set temp1 = 3
          lda # 3
          sta temp1
          ;; Set temp2 = PlayerLockedNormal
          lda # PlayerLockedNormal
          sta temp2
          ;; Cross-bank call to SetPlayerLocked in bank 5
          ;; Return address: ENCODED with caller bank 5 ($50) for BS_return to decode
          lda # ((>(AfterSetPlayerLockedP3Second-1)) & $0f) | $50  ;;; Encode bank 5 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterSetPlayerLockedP3Second hi (encoded)]
          lda # <(AfterSetPlayerLockedP3Second-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterSetPlayerLockedP3Second hi (encoded)] [SP+0: AfterSetPlayerLockedP3Second lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(SetPlayerLocked-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterSetPlayerLockedP3Second hi (encoded)] [SP+1: AfterSetPlayerLockedP3Second lo] [SP+0: SetPlayerLocked hi (raw)]
          lda # <(SetPlayerLocked-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterSetPlayerLockedP3Second hi (encoded)] [SP+2: AfterSetPlayerLockedP3Second lo] [SP+1: SetPlayerLocked hi (raw)] [SP+0: SetPlayerLocked lo]
          ldx # 5
          jmp BS_jsr
AfterSetPlayerLockedP3Second:

          ;; detection (upgrades only)
          ;; Controller detection is handled by DetectPads with
          ;; monotonic state machine

          ;; Initialize character select animations
          lda # 0
          sta characterSelectAnimationTimer
          ;; Start with idle animation
          lda # 0
          sta characterSelectAnimationState
          ;; Start with first character
          lda # 0
          sta characterSelectCharacterIndex_W
          lda # 0
          sta characterSelectAnimationFrame

          ;; Check for Quadtari adapter (inlined for performance)
          ;; CANONICAL QUADTARI DETECTION: Check paddle ports INPT0-3
          ;; Require BOTH sides present: Left (INPT0 LOW, INPT1 HIGH) and Right (INPT2 LOW, INPT3 HIGH)
          ;; If INPT0{7} is set, Quadtari absent
          lda INPT0
          bpl CheckINPT1
          jmp CharacterSelectQuadtariAbsent
CheckINPT1:

          ;; If !INPT1{7}, Quadtari absent
          lda INPT1
          bmi CheckINPT2
          jmp CharacterSelectQuadtariAbsent
CheckINPT2:

          ;; If INPT2{7} is set, Quadtari absent
          lda INPT2
          bpl CheckINPT3
          jmp CharacterSelectQuadtariAbsent
CheckINPT3:

          ;; All checks passed - Quadtari detected
          ;; If !INPT3{7}, Quadtari absent
          lda INPT3
          bmi CharacterSelectQuadtariPresent
          jmp CharacterSelectQuadtariAbsent
CharacterSelectQuadtariPresent:
          lda controllerStatus
          ora # SetQuadtariDetected
          sta controllerStatus

.bend

CharacterSelectQuadtariAbsent .block
          ;; Background: black (COLUBK starts black, no need to set)

          ;; Initialization complete - per-frame loop handled by CharacterSelectInputEntry
          ;; Far-call return: SetupCharacterSelect enters this routine with an
          ;; encoded return address, so it must exit through BS_return.
          jmp BS_return

.bend

