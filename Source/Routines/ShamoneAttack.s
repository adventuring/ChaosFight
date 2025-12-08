;;; ChaosFight - Source/Routines/ShamoneAttack.bas

;;; Copyright © 2025 Bruce-Robert Pocock.



ShamoneAttack
          ;; Returns: Far (return otherbank)


;; ShamoneAttack (duplicate)


          ;; Shamone (Character 15) - Special attack: jumps while
          ;; Returns: Far (return otherbank)

          ;; attacking simultaneously

          ;;
          ;; Input: temp1 = attacker player index (0-3)

          ;; playerY[] (global array) = player Y positions

          ;; playerState[] (global array) = player state flags

          ;; MaskPlayerStateFlags (constant) = bitmask to

          ;; preserve state flags

          ;; ActionAttackExecuteShifted (constant) = attack

          ;; execution animation sta


          ;;
          ;; Output: Player jumps 11 pixels up, mêlée attack executed

          ;;
          ;; Mutates: temp1 (used for calculations), playerY[] (moved

          ;; up 11 pixels), playerState[] (animation state set),

          ;; missile state (via PerformMeleeAttack)

          ;;
          ;; Called Routines: PerformMeleeAttack (bank7) - executes mêlée

          ;; attack, spawns missile

          ;;
          ;; Constraints: None

          ;; Special attack: jumps while attacking simultaneously

          ;; First, execute the jump

          ;; ;; let playerY[temp1] = playerY[temp1] - 11
          lda temp1
          asl
          tax
          dec playerY,x

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; dec playerY,x (duplicate)


          ;; Light character, good jump

                    ;; let playerState[temp1] = playerState[temp1] | PlayerStateBitJumping

          ;; Set jumping flag

          ;; Then execute the attack (inline former PerformMeleeAttack)

          ;; Cross-bank call to SpawnMissile in bank 7
          ;; lda # >(return_point_1_L88-1) (duplicate)
          pha
          ;; lda # <(return_point_1_L88-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(SpawnMissile-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(SpawnMissile-1) (duplicate)
          ;; pha (duplicate)
                    ldx # 6
          jmp BS_jsr
return_point_1_L88:


                    ;; let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionAttackExecuteShifted
          jsr BS_return




