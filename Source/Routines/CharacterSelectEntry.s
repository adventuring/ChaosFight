;;; ChaosFight - Source/Routines/CharacterSelectEntry.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


CharacterSelectEntry .proc
          ;; Initializes character select screen sta

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
          lda # 0
          asl
          tax
          lda # RandomCharacter
          sta playerCharacter,x
          ;; Player 3: NoCharacter (locked)
          lda # 1
          asl
          tax
          lda # CPUCharacter
          sta playerCharacter,x
          ;; Player 4: NoCharacter (locked)
          lda # 2
          asl
          tax
          lda # NoCharacter
          sta playerCharacter,x
          ;; Initialize playerLocked (bit-packed)
          lda # 3
          asl
          tax
          lda # NoCharacter
          sta playerCharacter,x
          ;; Lock Player 2 (CPUCharacter)
          lda # 0
          sta playerLocked
          ;; Lock Player 3 (NoCharacter)
          ;; let temp1 = 1 : let temp2 = PlayerLockedNormal : gosub SetPlayerLocked bank6

          ;; Lock Player 4 (NoCharacter)
          ;; let temp1 = 2
          lda # 2
          sta temp1 : let temp2 = PlayerLockedNormal : gosub SetPlayerLocked bank6

          ;; NOTE: Do NOT clear controllerStatus flags here - monotonic
          ;; let temp1 = 3
          lda # 3
          sta temp1 : let temp2 = PlayerLockedNormal : gosub SetPlayerLocked bank6

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
          ;; if INPT0{7} then goto CharacterSelectQuadtariAbsent

                    if !INPT1{7} then goto CharacterSelectQuadtariAbsent
          bit INPT1
          bmi skip_5888
          jmp CharacterSelectQuadtariAbsent
skip_5888:

          ;; if INPT2{7} then goto CharacterSelectQuadtariAbsent
          bit INPT2
          bpl skip_4108
          jmp CharacterSelectQuadtariAbsent
skip_4108:

          ;; All checks passed - Quadtari detected
                    if !INPT3{7} then goto CharacterSelectQuadtariAbsent
          bit INPT3
          bmi skip_7109
          jmp CharacterSelectQuadtariAbsent
skip_7109:
          lda controllerStatus
          ora SetQuadtariDetected
          sta controllerStatus

.pend

CharacterSelectQuadtariAbsent .proc
          ;; Background: black (COLUBK starts black, no need to set)

          ;; Initialization complete - per-frame loop handled by CharacterSelectInputEntry
          rts

.pend

