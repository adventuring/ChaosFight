          rem ChaosFight - Source/Routines/UrsuloAttack.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

UrsuloAttack
          asm
UrsuloAttack
end
          rem Ursulo (Character 14) - Mêlée attack (claw swipe)
          rem
          rem Input: temp1 = attacker player index (0-3)
          rem
          rem Output: Mêlée attack executed
          rem
          rem Mutates: playerState[] (animation state set), missile
          rem state (via PerformMeleeAttack)
          rem
          rem Called Routines: PerformMeleeAttack (bank7, tail call via goto) -
          rem executes mêlée attack, spawns missile
          rem
          rem Constraints: Tail call to PerformMeleeAttack
          rem Mêlée attack (claw swipe)
          goto PerformMeleeAttack bank7

