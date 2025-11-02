          rem ChaosFight - Source/Routines/CharacterAttacks.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem =================================================================
          rem CHARACTER-SPECIFIC ATTACK SUBROUTINES
          rem =================================================================
          rem Each character has a unique attack subroutine that:
          rem   1. Calls either PerformMeleeAttack or PerformRangedAttack
          rem   2. Sets the appropriate animation state
          rem   3. Handles any character-specific attack logic

          rem Input for all attack routines:
          rem   temp1 = attacker player index (0-3)

          rem All other needed data (X, Y, facing direction, etc.) is looked up
          rem from the player arrays using temp1 as the index

          rem =================================================================
          rem BERNIE (Character 0) - Melee Attack (Both Directions)
          rem =================================================================
BernieAttack
          rem Bernie special attack hits both left AND right simultaneously
          rem This is unique - all other melee attacks only hit in facing direction
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | (AnimAttackExecute << ShiftAnimationState) 
          rem Set animation state 14 (attack execution)
          
          rem Attack in facing direction
          gosub PerformMeleeAttack
          
          rem Also attack in opposite direction
          rem Temporarily flip facing
          let temp5 = playerState[temp1] & 1 
          rem Store original facing
          if temp5 <> 0 then FaceLeft1
          let playerState[temp1] = playerState[temp1] | 1 
          rem Face right
          goto FacingDone1
FaceLeft1
          let playerState[temp1] = playerState[temp1] & 254 
          rem Face left
FacingDone1
          
          rem Attack in opposite direction
          gosub PerformMeleeAttack
          
          rem Restore original facing
          if temp5 <> 0 then RestoreFaceRight1
          let playerState[temp1] = playerState[temp1] & 254
          goto RestoreFacingDone1
RestoreFaceRight1
          let playerState[temp1] = playerState[temp1] | 1
RestoreFacingDone1
          
          return

          rem =================================================================
          rem CURLER (Character 1) - Ranged Attack (ground-based)
          rem =================================================================
CurlerAttack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | (AnimAttackExecute << ShiftAnimationState) 
          rem Set animation state 14 (attack execution)
          gosub PerformRangedAttack
          return

          rem =================================================================
          rem DRAGONET (Character 2) - Melee Attack
          rem =================================================================
DragonetAttack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | (AnimAttackExecute << ShiftAnimationState) 
          rem Set animation state 14 (attack execution)
          gosub PerformMeleeAttack
          return

          rem =================================================================
          rem ZOE RYEN (Character 3) - Ranged Attack
          rem =================================================================
ZoeRyenAttack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | (AnimAttackExecute << ShiftAnimationState) 
          rem Set animation state 14 (attack execution)
          gosub PerformRangedAttack
          return

          rem =================================================================
          rem FAT TONY (Character 4) - Melee Attack
          rem =================================================================
FatTonyAttack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | (AnimAttackExecute << ShiftAnimationState) 
          rem Set animation state 14 (attack execution)
          gosub PerformRangedAttack
          return

          rem =================================================================
          rem GRIZZARD HANDLER (Character 5) - Ranged Attack (Grizzard Eggs)
          rem =================================================================
MegaxAttack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | (AnimAttackExecute << ShiftAnimationState) 
          rem Set animation state 14 (attack execution)
          gosub PerformRangedAttack
          return

          rem =================================================================
          rem HARPY (Character 6) - Diagonal Downward Attack
          rem =================================================================
          rem Harpy attack is a downward diagonal projectile in facing direction
HarpyAttack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | (AnimAttackExecute << ShiftAnimationState) 
          rem Set animation state 14 (attack execution)
          gosub PerformRangedAttack
          rem Spawns diagonal downward missile (velocity set in character data)
          return

          rem =================================================================
          rem KNIGHT GUY (Character 7) - Ranged Attack
          rem =================================================================
KnightGuyAttack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | (AnimAttackExecute << ShiftAnimationState) 
          rem Set animation state 14 (attack execution)
          gosub PerformRangedAttack
          return

          rem =================================================================
          rem FROOTY (Character 8) - Ranged Attack
          rem =================================================================
FrootyAttack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | (AnimAttackExecute << ShiftAnimationState) 
          rem Set animation state 14 (attack execution)
          gosub PerformRangedAttack
          return

          rem =================================================================
          rem NEFERTEM (Character 9) - Melee Attack
          rem =================================================================
NefertemAttack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | (AnimAttackExecute << ShiftAnimationState) 
          rem Set animation state 14 (attack execution)
          gosub PerformMeleeAttack
          return

          rem =================================================================
          rem NINJISH GUY (Character 10) - Ranged Attack (small bullet)
          rem =================================================================
NinjishGuyAttack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | (AnimAttackExecute << ShiftAnimationState) 
          rem Set animation state 14 (attack execution)
          gosub PerformRangedAttack
          return

          rem =================================================================
          rem PORK CHOP (Character 11) - Melee Attack
          rem =================================================================
PorkChopAttack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | (AnimAttackExecute << ShiftAnimationState) 
          rem Set animation state 14 (attack execution)
          gosub PerformMeleeAttack
          return

          rem =================================================================
          rem RADISH GOBLIN (Character 12) - Melee Attack
          rem =================================================================
RadishGoblinAttack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | (AnimAttackExecute << ShiftAnimationState) 
          rem Set animation state 14 (attack execution)
          gosub PerformMeleeAttack
          return

          rem =================================================================
          rem ROBO TITO (Character 13) - Melee Attack
          rem =================================================================
RoboTitoAttack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | (AnimAttackExecute << ShiftAnimationState) 
          rem Set animation state 14 (attack execution)
          gosub PerformMeleeAttack
          return

          rem =================================================================
          rem URSULO (Character 14) - Ranged Attack
          rem =================================================================
UrsuloAttack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | (AnimAttackExecute << ShiftAnimationState) 
          rem Set animation state 14 (attack execution)
          gosub PerformRangedAttack
          return

          rem =================================================================
          rem SHAMONE (Character 15) - Jump + Attack (Special)
          rem =================================================================
          rem Shamone special attack: jumps while attacking simultaneously
ShamoneAttack
          rem First, execute the jump
          let playerY[temp1] = playerY[temp1] - 11 
          rem Light character, good jump
          let playerState[temp1] = playerState[temp1] | (1 << PlayerStateJumping)
          rem Set jumping flag
          
          rem Then execute the attack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | (AnimAttackExecute << ShiftAnimationState) 
          rem Set animation state 14 (attack execution)
          gosub PerformMeleeAttack
          return

          rem =================================================================
          rem CHARACTER ATTACK DISPATCHER
          rem =================================================================
          rem Routes to the appropriate character attack subroutine based on character type

          rem INPUT:
          rem   temp1 = attacker player index (0-3)

          rem All character attack routines will look up playerX[temp1], playerY[temp1],
          rem playerState[temp1], etc. as needed.

DispatchCharacterAttack
          rem Get character type for this player using direct array access
          rem temp1 contains player index (0-3)
          let temp2 = playerChar[temp1]
          rem Map MethHound (31) to ShamoneAttack handler
          if temp2 = 31 then temp2 = AnimAttackRecovery
          rem Use Shamone attack for MethHound
          on temp2 goto BernieAttack, CurlerAttack, DragonetAttack, ZoeRyenAttack, FatTonyAttack, MegaxAttack, HarpyAttack, KnightGuyAttack, FrootyAttack, NefertemAttack, NinjishGuyAttack, PorkChopAttack, RadishGoblinAttack, RoboTitoAttack, UrsuloAttack, ShamoneAttack
          rem Default to Bernie attack if invalid character
          goto BernieAttack