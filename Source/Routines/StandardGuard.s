;;; ChaosFight - Source/Routines/StandardGuard.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


StandardGuard .proc
          ;; Standard guard behavior
          ;;
          ;; INPUT: temp1 = player index
          ;; USES: playerState[temp1], playerTimers[temp1]
          ;; Used by: Bernie, Curler, Zoe Ryen, Fat Tony, Megax, Knight Guy,
          ;; Nefertem, Ninjish Guy, Pork Chop, Radish Goblin, Ursulo,
          ;; Shamone, MethHound, and placeholder characters (16-30)
          ;; NOTE: Flying characters (Frooty, Dragon of Storms, Harpy)
          ;; cannot guard
          ;; Standard guard behavior used by most characters (blocks
          ;; attacks, forces cyan guard tint)
          ;;
          ;; Input: temp1 = player index (0-3), playerCharacter[] (global
          ;; array) = character types
          ;;
          ;; Output: Guard activated if allowed (not flying character,
          ;; not in cooldown)
          ;;
          ;; Mutates: temp1-temp4 (used for calculations),
          ;; playerState[] (global arrays) = player
          ;; states and timers (via StartGuard)
          ;;
          ;; Called Routines: CheckGuardCooldown (bank6) - checks
          ;; guard cooldown, StartGuard (bank6) - activates guard
          ;;
          ;; Constraints: Flying characters (Frooty=8, Dragon of
          ;; Storms=2, Harpy=6) cannot guard. Guard blocked if in
          ;; cooldown
          ;; Flying characters cannot guard - DOWN is used for vertical
          ;; movement
          ;; Frooty (8): DOWN = fly down (no gravity)
          ;; Dragon of Storms (2): DOWN = fly down (no gravity)
          ;; Harpy (6): DOWN = fly down (reduced gravity)
          ;; let temp4 = playerCharacter[temp1]         
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp4

          ;; Check if guard is allowed (not in cooldown)

          ;; Cross-bank call to CheckGuardCooldown in bank 6
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(CheckGuardCooldown-1)
          pha
          lda # <(CheckGuardCooldown-1)
          pha
          ldx # 5
          jmp BS_jsr

return_point:

          ;; Guard blocked by cooldown
          lda temp2
          cmp # 0
          bne ActivateGuard

          jsr BS_return

ActivateGuard:

          ;; Activate guard state - inlined (StartGuard)

          ;; Set guard bit in playerState

          let playerState[temp1] = playerState[temp1] | 2

          ;; Set guard duration timer
          lda temp1
          asl
          tax
          lda # GuardTimerMaxFrames
          sta playerTimers_W,x

          jsr BS_return

.pend

