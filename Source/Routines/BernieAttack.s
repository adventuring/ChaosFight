;;; ChaosFight - Source/Routines/BernieAttack.bas

;;; Copyright © 2025 Bruce-Robert Pocock.


BernieAttack .proc
          ;; Executes Bernies ground-thump area attack
          ;; Returns: Far (return otherbank)

          ;; Each character has a unique attack subroutine that:

          ;; 1. Calls either PerformMeleeAttack or PerformRangedAttack

          ;; 2. Sets the appropriate animation sta


          ;; 3. Handles any character-specific attack logic

          ;; Input for all attack routines:

          ;; temp1 = attacker player index (0-3)

          ;;
          ;; All other needed data (X,y, facing direction, etc.) is

          ;; looked up

          ;; from the player arrays using temp1 as the index

          ;; Bernie (character 0) - Ground Thump area-of-effect attack

          ;;
          ;; Input: temp1 = attacker player index (0-3)

          ;; playerState[] (global array) = player state flags

          ;; MaskPlayerStateFlags (constant) = bitmask to

          ;; preserve state flags

          ;; ActionAttackExecuteShifted (constant) = attack

          ;; execution animation sta


          ;; PlayerStateBitFacing (constant) = facing direction

          ;; bit

          ;;
          ;; Output: Two mêlée attacks executed (left and right),

          ;; facing direction restored

          ;;
          ;; Mutates: temp1, temp3 (used for calculations),

          ;; playerState[] (animation state set, facing toggled and

          ;; restored),

          ;; missile state (via PerformMeleeAttack)

          ;;
          ;; Called Routines: PerformMeleeAttack (bank7) - executes mêlée

          ;; attack via shared tables

          ;; Constraints: None

          ;; Area-of-effect attack: hits both left and right

          ;; simultaneously

          ;; Save original facing direction

          ;; Set animation state (PerformMeleeAttack also sets it, but

          ;; we need it set first)

          ;; let temp3 = playerState[temp1] & PlayerStateBitFacing         
          lda temp1
          asl
          tax
          lda playerState,x
          and # PlayerStateBitFacing
          sta temp3

          ;; Attack in facing direction (inline former PerformMeleeAttack)
          ;; Set attack animation state
          lda temp1
          asl
          tax
          lda playerState,x
          and # MaskPlayerStateFlags
          ora # ActionAttackExecuteShifted
          sta playerState,x

          ;; Attack facing direction
          ;; Cross-bank call to PerformGenericAttack in bank 7
          lda # >(AfterPerformGenericAttackFacing-1)
          pha
          lda # <(AfterPerformGenericAttackFacing-1)
          pha
          lda # >(PerformGenericAttack-1)
          pha
          lda # <(PerformGenericAttack-1)
          pha
                    ldx # 6
          jmp BS_jsr
AfterPerformGenericAttackFacing:


          ;; Attack opposite direction (toggle facing)
          ;; Toggle facing direction bit
          lda temp1
          asl
          tax
          lda playerState,x
          eor # PlayerStateBitFacing
          sta playerState,x

          ;; Cross-bank call to PerformGenericAttack in bank 7
          lda # >(AfterPerformGenericAttackOpposite-1)
          pha
          lda # <(AfterPerformGenericAttackOpposite-1)
          pha
          lda # >(PerformGenericAttack-1)
          pha
          lda # <(PerformGenericAttack-1)
          pha
                    ldx # 6
          jmp BS_jsr
AfterPerformGenericAttackOpposite:


          ;; Restore original facing direction
          ;; Restore saved facing direction from temp3
          lda temp1
          asl
          tax
          lda playerState,x
          and # MaskPlayerStateFlags
          ora temp3
          sta playerState,x
          jmp BS_return

.pend

