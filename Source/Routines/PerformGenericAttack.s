
PerformGenericAttack .proc
          ;; ChaosFight - Source/Routines/PerformGenericAttack.bas
          ;; Copyright © 2025 Bruce-Robert Pocock.
          ;; Perform Generic Attack (Mêlée or Ranged)
          ;; Executes a generic attack for the specified player.
          ;; Spawns a missile visual (sword, fist, projectile, etc.) and
          ;; sets animation state. Attack type (mêlée vs ranged) is
          ;; determined by SpawnMissile based on character.
          ;;
          ;; Input: temp1 = attacker player index (0-3)
          ;; playerState[] (global array) = player state flags
          ;; MaskPlayerStateFlags (constant) = bitmask to
          ;; preserve state flags
          ;; ActionAttackExecuteShifted (constant) = attack
          ;; execution animation sta

          ;;
          ;; Output: Missile spawned, playerState[] animation state set
          ;; to attacking
          ;;
          ;; Mutates: playerState[] (animation state set to
          ;; ActionAttackExecuteShifted),
          ;; missile state (via SpawnMissile)
          ;;
          ;; Called Routines: SpawnMissile - spawns missile
          ;; visual for attack (determines mêlée vs ranged)
          ;;
          ;; Constraints: None
          ;; Spawn missile visual for this attack
          ;; Cross-bank call to SpawnMissile in bank 7
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(SpawnMissile-1)
          pha
          lda # <(SpawnMissile-1)
          pha
                    ldx # 6
          jmp BS_jsr
return_point:


          ;; Set animation state to attacking
                    let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionAttackExecuteShifted
          ;; Set animation state 14 (attack execution)
          ;; Check immediate collision with other players in mêlée
          ;; range
          ;; This is handled by the main collision detection system
          ;; For now, collision will be handled in UpdateAllMissiles
          jsr BS_return



.pend

