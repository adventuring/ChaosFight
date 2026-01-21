;;; ChaosFight - Source/Routines/UrsuloAttack.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


UrsuloAttack .proc
          ;; Ursulo (Character 14) - Mêlée attack (claw swipe)
          ;;
          ;; Input: temp1 = attacker player index (0-3)
          ;;
          ;; Output: Mêlée attack executed
          ;;
          ;; Mutates: playerState[] (animation state set), missile
          ;; state (via PerformGenericAttack)
          ;;
          ;; Called Routines: PerformGenericAttack (bank7, tail call via goto) -
          ;; executes generic attack, spawns missile
          ;;
          ;; Constraints: Tail call to PerformGenericAttack
          ;; Mêlée attack (claw swipe)
          jmp PerformGenericAttack


.pend

