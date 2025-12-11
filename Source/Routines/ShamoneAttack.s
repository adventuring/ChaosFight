;;; ChaosFight - Source/Routines/ShamoneAttack.bas

;;; Copyright © 2025 Bruce-Robert Pocock.



ShamoneAttack:
          ;; Returns: Far (return otherbank)
          ;; Shamone (Character 15) - Special attack: jumps while
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

          ;; let playerY[temp1] = playerY[temp1] - 11
          lda temp1
          asl
          tax
          lda playerY,x
          sec
          sbc # 11
          sta playerY,x

          ;; Light character, good jump
          ;; Set jumping flag
          lda temp1
          asl
          tax
          lda playerState,x
          ora # PlayerStateBitJumping
          sta playerState,x

          ;; Set jumping flag

          ;; Then execute the attack (inline former PerformMeleeAttack)

          ;; Cross-bank call to SpawnMissile in bank 7
          lda # >(ShamoneAttackSpawnMissileReturn-1)
          pha
          lda # <(ShamoneAttackSpawnMissileReturn-1)
          pha
          lda # >(SpawnMissile-1)
          pha
          lda # <(SpawnMissile-1)
          pha
          ldx # 6
          jmp BS_jsr

ShamoneAttackSpawnMissileReturn:
          ;; Set attack animation state
          lda temp1
          asl
          tax
          lda playerState,x
          and # MaskPlayerStateFlags
          ora # ActionAttackExecuteShifted
          sta playerState,x
          jmp BS_return




