          rem ChaosFight - Source/Routines/ProcessAttackInput.bas

          rem Copyright © 2025 Bruce-Robert Pocock.



ProcessAttackInput

          asm

ProcessAttackInput



end

          rem

          rem Shared Attack Input Handler

          rem Handles attack input (fire button) for both ports

          rem Uses temp1 & 2 pattern to select joy0 vs joy1

          rem

          rem INPUT: temp1 = player index (0-3), temp2 = cached animation state

          rem Uses: joy0fire for players 0,2; joy1fire for players 1,3

          rem

          rem OUTPUT: Attack executed if conditions met

          rem

          rem Mutates: temp2, temp4, playerCharacter[]

          rem

          rem Called Routines: DispatchCharacterAttack (bank10)

          rem

          rem Constraints: Must be colocated with PAI_UseJoy0 helper

          rem Process attack input

          rem Map MethHound (31) to ShamoneAttack handler

          rem Use cached animation state - block attack input during attack

          rem animations (states 13-15)

          rem Block attack input during attack windup/execute/recovery

          if temp2 >= 13 then return otherbank

          rem Check if player is guarding - guard blocks attacks

          let temp2 = playerState[temp1] & 2

          rem Guarding - block attack input

          if temp2 then return otherbank

          rem Determine which joy port to use based on player index

          

          rem Players 0,2 use joy0 (left port); Players 1,3 use joy1 (right port)

          rem Players 1,3 use joy1

          if temp1 & 2 = 0 then PAI_UseJoy0

          if !joy1fire then return otherbank

          goto PAI_ExecuteAttack

          

PAI_UseJoy0

          rem Players 0,2 use joy0

          if !joy0fire then return thisbank

          

PAI_ExecuteAttack

          if (playerState[temp1] & PlayerStateBitFacing) then return thisbank

          let temp4 = playerCharacter[temp1]

          gosub DispatchCharacterAttack bank10

          return thisbank


