PerformGenericAttack

          asm
PerformGenericAttack
end
          rem ChaosFight - Source/Routines/PerformGenericAttack.bas
          rem Copyright © 2025 Bruce-Robert Pocock.
          rem Perform Generic Attack (Mêlée or Ranged)
          rem Executes a generic attack for the specified player.
          rem Spawns a missile visual (sword, fist, projectile, etc.) and
          rem   sets animation state. Attack type (mêlée vs ranged) is
          rem   determined by SpawnMissile based on character.
          rem
          rem Input: temp1 = attacker player index (0-3)
          rem        playerState[] (global array) = player state flags
          rem        MaskPlayerStateFlags (constant) = bitmask to
          rem        preserve state flags
          rem        ActionAttackExecuteShifted (constant) = attack
          rem        execution animation state
          rem
          rem Output: Missile spawned, playerState[] animation state set
          rem to attacking
          rem
          rem Mutates: playerState[] (animation state set to
          rem ActionAttackExecuteShifted),
          rem         missile state (via SpawnMissile)
          rem
          rem Called Routines: SpawnMissile - spawns missile
          rem visual for attack (determines mêlée vs ranged)
          rem
          rem Constraints: None
          rem Spawn missile visual for this attack
          gosub SpawnMissile bank7

          rem Set animation state to attacking
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionAttackExecuteShifted
          rem Set animation state 14 (attack execution)
          rem Check immediate collision with other players in mêlée
          rem   range
          rem This is handled by the main collision detection system
          rem For now, collision will be handled in UpdateAllMissiles
          return otherbank


