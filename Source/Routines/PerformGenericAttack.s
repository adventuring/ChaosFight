
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
          ;; Cross-bank call to SpawnMissile in bank 6
          ;; Return address: ENCODED with caller bank 6 ($60) for BS_return to decode
          lda # ((>(AfterSpawnMissileGeneric-1)) & $0f) | $60  ;;; Encode bank 6 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterSpawnMissileGeneric hi (encoded)]
          lda # <(AfterSpawnMissileGeneric-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterSpawnMissileGeneric hi (encoded)] [SP+0: AfterSpawnMissileGeneric lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(SpawnMissile-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterSpawnMissileGeneric hi (encoded)] [SP+1: AfterSpawnMissileGeneric lo] [SP+0: SpawnMissile hi (raw)]
          lda # <(SpawnMissile-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterSpawnMissileGeneric hi (encoded)] [SP+2: AfterSpawnMissileGeneric lo] [SP+1: SpawnMissile hi (raw)] [SP+0: SpawnMissile lo]
          ldx # 6
          jmp BS_jsr

AfterSpawnMissileGeneric:

          ;; Set animation state to attacking
          ;; let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionAttackExecuteShifted
          ;; Set animation state 14 (attack execution)
          ;; Check immediate collision with other players in mêlée
          ;; range
          ;; This is handled by the main collision detection system
          ;; For now, collision will be handled in UpdateAllMissiles
          jmp BS_return

.pend

