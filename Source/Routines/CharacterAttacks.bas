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
rem   temp2 = attacker X position
rem   temp3 = attacker Y position
rem   temp4 = attacker facing direction (0=left, 1=right)

rem =================================================================
rem BERNIE (Character 0) - Melee Attack
rem =================================================================
BernieAttack
  rem Bernie uses a melee attack
  rem Set attack animation state (13 = attack windup, 14 = attack execution)
  rem temp1 contains player index, set animation state directly
  PlayerState[temp1] = PlayerState[temp1] | 16  : rem Set attacking bit
  gosub PerformMeleeAttack
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
rem Input: temp1 = attacker player index (0-3)
rem        temp2 = attacker X position
rem        temp3 = attacker Y position
rem        temp4 = attacker facing direction (0=left, 1=right)

DispatchCharacterAttack
  rem Get character type for this player using direct array access
  rem temp1 contains player index (0-3)
  temp4 = PlayerChar[temp1]
  on temp4 goto BernieAttack, CurlingSweeperAttack, DragonetAttack, EXOPilotAttack, FatTonyAttack, GrizzardHandlerAttack, HarpyAttack, KnightGuyAttack, MagicalFaerieAttack, MysteryManAttack, NinjishGuyAttack, PorkChopAttack, RadishGoblinAttack, RoboTitoAttack, UrsuloAttack, VegDogAttack
  rem Default to Bernie attack if invalid character
  goto BernieAttack
