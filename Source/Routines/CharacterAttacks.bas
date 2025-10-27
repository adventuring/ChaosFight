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
rem
rem All other needed data (X, Y, facing direction, etc.) is looked up
rem from the player arrays using temp1 as the index

rem =================================================================
rem BERNIE (Character 0) - Melee Attack (Both Directions)
rem =================================================================
BernieAttack
  rem Bernie's special attack hits both left AND right simultaneously
  rem This is unique - all other melee attacks only hit in facing direction
  PlayerState[temp1] = PlayerState[temp1] | 16  : rem Set attacking bit
  
  rem Attack in facing direction
  gosub PerformMeleeAttack
  
  rem Also attack in opposite direction
  rem Temporarily flip facing
  temp5 = PlayerState[temp1] & 1  : rem Store original facing
  if temp5 = 0 then
    PlayerState[temp1] = PlayerState[temp1] | 1  : rem Face right
  else
    PlayerState[temp1] = PlayerState[temp1] & ~1  : rem Face left
  endif
  
  rem Attack in opposite direction
  gosub PerformMeleeAttack
  
  rem Restore original facing
  if temp5 = 0 then
    PlayerState[temp1] = PlayerState[temp1] & ~1
  else
    PlayerState[temp1] = PlayerState[temp1] | 1
  endif
  
  return

rem =================================================================
rem CURLING SWEEPER (Character 1) - Ranged Attack (ground-based)
rem =================================================================
CurlingSweeperAttack
  PlayerState[temp1] = PlayerState[temp1] | 16  : rem Set attacking bit
  gosub PerformRangedAttack
  return

rem =================================================================
rem DRAGONET (Character 2) - Melee Attack
rem =================================================================
DragonetAttack
  PlayerState[temp1] = PlayerState[temp1] | 16  : rem Set attacking bit
  gosub PerformMeleeAttack
  return

rem =================================================================
rem EXO PILOT (Character 3) - Ranged Attack
rem =================================================================
EXOPilotAttack
  PlayerState[temp1] = PlayerState[temp1] | 16  : rem Set attacking bit
  gosub PerformRangedAttack
  return

rem =================================================================
rem FAT TONY (Character 4) - Melee Attack
rem =================================================================
FatTonyAttack
  PlayerState[temp1] = PlayerState[temp1] | 16  : rem Set attacking bit
  gosub PerformMeleeAttack
  return

rem =================================================================
rem GRIZZARD HANDLER (Character 5) - Melee Attack
rem =================================================================
GrizzardHandlerAttack
  PlayerState[temp1] = PlayerState[temp1] | 16  : rem Set attacking bit
  gosub PerformMeleeAttack
  return

rem =================================================================
rem HARPY (Character 6) - Melee Attack
rem =================================================================
HarpyAttack
  PlayerState[temp1] = PlayerState[temp1] | 16  : rem Set attacking bit
  gosub PerformMeleeAttack
  return

rem =================================================================
rem KNIGHT GUY (Character 7) - Ranged Attack
rem =================================================================
KnightGuyAttack
  PlayerState[temp1] = PlayerState[temp1] | 16  : rem Set attacking bit
  gosub PerformRangedAttack
  return

rem =================================================================
rem MAGICAL FAERIE (Character 8) - Ranged Attack
rem =================================================================
MagicalFaerieAttack
  PlayerState[temp1] = PlayerState[temp1] | 16  : rem Set attacking bit
  gosub PerformRangedAttack
  return

rem =================================================================
rem MYSTERY MAN (Character 9) - Melee Attack
rem =================================================================
MysteryManAttack
  PlayerState[temp1] = PlayerState[temp1] | 16  : rem Set attacking bit
  gosub PerformMeleeAttack
  return

rem =================================================================
rem NINJISH GUY (Character 10) - Ranged Attack (small bullet)
rem =================================================================
NinjishGuyAttack
  PlayerState[temp1] = PlayerState[temp1] | 16  : rem Set attacking bit
  gosub PerformRangedAttack
  return

rem =================================================================
rem PORK CHOP (Character 11) - Melee Attack
rem =================================================================
PorkChopAttack
  PlayerState[temp1] = PlayerState[temp1] | 16  : rem Set attacking bit
  gosub PerformMeleeAttack
  return

rem =================================================================
rem RADISH GOBLIN (Character 12) - Melee Attack
rem =================================================================
RadishGoblinAttack
  PlayerState[temp1] = PlayerState[temp1] | 16  : rem Set attacking bit
  gosub PerformMeleeAttack
  return

rem =================================================================
rem ROBO TITO (Character 13) - Melee Attack
rem =================================================================
RoboTitoAttack
  PlayerState[temp1] = PlayerState[temp1] | 16  : rem Set attacking bit
  gosub PerformMeleeAttack
  return

rem =================================================================
rem URSULO (Character 14) - Ranged Attack
rem =================================================================
UrsuloAttack
  PlayerState[temp1] = PlayerState[temp1] | 16  : rem Set attacking bit
  gosub PerformRangedAttack
  return

rem =================================================================
rem VEG DOG (Character 15) - Melee Attack
rem =================================================================
VegDogAttack
  PlayerState[temp1] = PlayerState[temp1] | 16  : rem Set attacking bit
  gosub PerformMeleeAttack
  return

rem =================================================================
rem CHARACTER ATTACK DISPATCHER
rem =================================================================
rem Routes to the appropriate character attack subroutine based on character type
rem
rem INPUT:
rem   temp1 = attacker player index (0-3)
rem
rem All character attack routines will look up PlayerX[temp1], PlayerY[temp1],
rem PlayerState[temp1], etc. as needed.

DispatchCharacterAttack
  rem Get character type for this player using direct array access
  rem temp1 contains player index (0-3)
  temp2 = PlayerChar[temp1]
  on temp2 goto BernieAttack, CurlingSweeperAttack, DragonetAttack, EXOPilotAttack, FatTonyAttack, GrizzardHandlerAttack, HarpyAttack, KnightGuyAttack, MagicalFaerieAttack, MysteryManAttack, NinjishGuyAttack, PorkChopAttack, RadishGoblinAttack, RoboTitoAttack, UrsuloAttack, VegDogAttack
  rem Default to Bernie attack if invalid character
  goto BernieAttack
