          rem ChaosFight - Source/Routines/UrsuloAttack.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

UrsuloAttack
          asm
UrsuloAttack
end
          rem Ursulo (Character 14) - Melee attack (claw swipe)
          rem
          rem Input: temp1 = attacker player index (0-3)
          rem
          rem Output: Melee attack executed
          rem
          rem Mutates: playerState[] (animation state set), missile
          rem state (via PerformMeleeAttack)
          rem
          rem Called Routines: PerformMeleeAttack (bank7, tail call via goto) -
          rem executes melee attack, spawns missile
          rem
          rem Constraints: Tail call to PerformMeleeAttack
          rem Melee attack (claw swipe)
          goto PerformMeleeAttack bank7

