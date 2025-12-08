;;; ChaosFight - Source/Routines/CharacterSelectEntry.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


CharacterSelectEntry .proc
;;; Initializes character select screen sta

          ;; Notes: PlayerLockedHelpers.bas resides in Bank 6
          ;;
          ;; Input: None (entry point)
          ;;
          ;; Output: playerCharacter[] initialized, playerLocked
          ;; initialized, animation state initialized,
          ;; COLUBK set, Quadtari detection called
          ;;
          ;; Mutates: playerCharacter[0-3] (P1=RandomCharacter, P2=CPUCharacter,
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
          ;; Player 2: CPUCharacter (locked)
          lda 0
          asl
          tax
          ;; lda RandomCharacter (duplicate)
          sta playerCharacter,x
          ;; Player 3: NoCharacter (locked)
          ;; lda 1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CPUCharacter (duplicate)
          ;; sta playerCharacter,x (duplicate)
          ;; Player 4: NoCharacter (locked)
          ;; lda 2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda NoCharacter (duplicate)
          ;; sta playerCharacter,x (duplicate)
          ;; Initialize playerLocked (bit-packed)
          ;; lda 3 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda NoCharacter (duplicate)
          ;; sta playerCharacter,x (duplicate)
          ;; Lock Player 2 (CPUCharacter)
          ;; lda # 0 (duplicate)
          ;; sta playerLocked (duplicate)
          ;; Lock Player 3 (NoCharacter)
                    ;; let temp1 = 1 : let temp2 = PlayerLockedNormal : gosub SetPlayerLocked bank6

          ;; Lock Player 4 (NoCharacter)
                    ;; let temp1 = 2
          ;; lda # 2 (duplicate)
          ;; sta temp1 : let temp2 = PlayerLockedNormal : gosub SetPlayerLocked bank6 (duplicate)

          ;; NOTE: Do NOT clear controllerStatus flags here - monotonic
                    ;; let temp1 = 3
          ;; lda # 3 (duplicate)
          ;; sta temp1 : let temp2 = PlayerLockedNormal : gosub SetPlayerLocked bank6 (duplicate)

          ;; detection (upgrades only)
          ;; Controller detection is handled by DetectPads with
          ;; monotonic state machine

          ;; Initialize character select animations
          ;; lda # 0 (duplicate)
          ;; sta characterSelectAnimationTimer (duplicate)
          ;; Start with idle animation
          ;; lda # 0 (duplicate)
          ;; sta characterSelectAnimationState (duplicate)
          ;; Start with first character
          ;; lda # 0 (duplicate)
          ;; sta characterSelectCharacterIndex_W (duplicate)
          ;; lda # 0 (duplicate)
          ;; sta characterSelectAnimationFrame (duplicate)

          ;; Check for Quadtari adapter (inlined for performance)
          ;; CANONICAL QUADTARI DETECTION: Check paddle ports INPT0-3
          ;; Require BOTH sides present: Left (INPT0 LOW, INPT1 HIGH) and Right (INPT2 LOW, INPT3 HIGH)
                    ;; if INPT0{7} then goto CharacterSelectQuadtariAbsent

                    ;; if !INPT1{7} then goto CharacterSelectQuadtariAbsent
          bit INPT1
          bmi skip_5888
          jmp CharacterSelectQuadtariAbsent
skip_5888:

                    ;; if INPT2{7} then goto CharacterSelectQuadtariAbsent
          ;; bit INPT2 (duplicate)
          bpl skip_4108
          ;; jmp CharacterSelectQuadtariAbsent (duplicate)
skip_4108:

          ;; All checks passed - Quadtari detected
                    ;; if !INPT3{7} then goto CharacterSelectQuadtariAbsent
          ;; bit INPT3 (duplicate)
          ;; bmi skip_7109 (duplicate)
          ;; jmp CharacterSelectQuadtariAbsent (duplicate)
skip_7109:
          ;; lda controllerStatus (duplicate)
          ora SetQuadtariDetected
          ;; sta controllerStatus (duplicate)

.pend

CharacterSelectQuadtariAbsent .proc
          ;; Background: black (COLUBK starts black, no need to set)

          ;; Initialization complete - per-frame loop handled by CharacterSelectInputEntry
          rts

.pend

