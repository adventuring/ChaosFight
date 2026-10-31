# SCRAM Variable Usage Bug Report

## Crash Description
Crash at PC $d25a with "writing with a read port" error indicates incorrect usage of SCRAM write/read ports.

## Root Cause
Multiple variables in Variables.s are sharing the same physical SCRAM addresses for both write and read operations, causing cross-contamination and potential crashes.

## BUGS IDENTIFIED

### BUG 1: player4Input_W and eliminationEffectTimer_W share write port $d063
**File:** `/home/brpocock/Projects/ChaosFight/Source/Common/Variables.s`
- Line 544: `player4Input_W = $d063`
- Line 686: `eliminationEffectTimer_W = $d063`
**Issue:** Both variables use the same write port - writing to one corrupts the other

### BUG 2: player4Input_R and eliminationEffectTimer_R share read port $d0E3
**File:** `/home/brpocock/Projects/ChaosFight/Source/Common/Variables.s`
- Line 548: `player4Input_R = player4Input_W | $80` (calculates to $d0E3)
- Line 688: `eliminationEffectTimer_R = $d0E3`
**Issue:** Both variables use the same read port - reading from one returns the other's value

### BUG 3: enhancedButtonStates_W and playerAttackCooldown_W share write port $d05A
**File:** `/home/brpocock/Projects/ChaosFight/Source/Common/Variables.s`
- Line 903: `enhancedButtonStates_W = $d05A`
- Line 670: `playerAttackCooldown_W = $d05A`
**Issue:** Both variables share the same write port

### BUG 4: enhancedButtonStates_R and playerAttackCooldown_R share read port $d0DA
**File:** `/home/brpocock/Projects/ChaosFight/Source/Common/Variables.s`
- Line 912: `enhancedButtonStates_R = $d0DA`
- Line 671: `playerAttackCooldown_R = $d0DA`
**Issue:** Both variables share the same read port

### BUG 5: player3Input_W and gameEndTimer_W share write port $d062
**File:** `/home/brpocock/Projects/ChaosFight/Source/Common/Variables.s`
- Line 543: `player3Input_W = $d062`
- Line 683: `gameEndTimer_W = $d062`
**Issue:** Both variables share the same write port

### BUG 6: player3Input_R and gameEndTimer_R share read port $d0E2
**File:** `/home/brpocock/Projects/ChaosFight/Source/Common/Variables.s`
- Line 547: `player3Input_R = player3Input_W | $80` (calculates to $d0E2)
- Line 684: `gameEndTimer_R = $d0E2`
**Issue:** Both variables share the same read port

### BUG 7: displayRank_W and frootyChargeState_W share write port $d06C
**File:** `/home/brpocock/Projects/ChaosFight/Source/Common/Variables.s`
- Line 700: `displayRank_W = $d06C`
- Line 715: `frootyChargeState_W = $d06C`
**Issue:** Both variables share the same write port

### BUG 8: displayRank_R and frootyChargeState_R share read port $d0EC
**File:** `/home/brpocock/Projects/ChaosFight/Source/Common/Variables.s`
- Line 701: `displayRank_R = $d0EC`
- Line 716: `frootyChargeState_R = $d0EC`
**Issue:** Both variables share the same read port

### BUG 9: eliminationOrder_W and distanceUp_W share write port $d069
**File:** `/home/brpocock/Projects/ChaosFight/Source/Common/Variables.s`
- Line 690: `eliminationOrder_W = $d069`
- Line 1077: `distanceUp_W = $d069`
**Issue:** Both variables share the same write port

### BUG 10: eliminationOrder_R and distanceUp_R share read port $d0E9
**File:** `/home/brpocock/Projects/ChaosFight/Source/Common/Variables.s`
- Line 692: `eliminationOrder_R = $d0E9`
- Line 1081: `distanceUp_R = $d0E9`
**Issue:** Both variables share the same read port

### BUG 11: originalPlayerY_W and frootyChargeTimer_W share write port $d068
**File:** `/home/brpocock/Projects/ChaosFight/Source/Common/Variables.s`
- Line 1069: `originalPlayerY_W = $d068`
- Line 710: `frootyChargeTimer_W = $d068`
**Issue:** Both variables share the same write port

### BUG 12: originalPlayerY_R and frootyChargeTimer_R share read port $d0E8
**File:** `/home/brpocock/Projects/ChaosFight/Source/Common/Variables.s`
- Line 1075: `originalPlayerY_R = $d0E8`
- Line 711: `frootyChargeTimer_R = $d0E8`
**Issue:** Both variables share the same read port

## Files with problematic code

### File: `/home/brpocock/Projects/ChaosFight/Source/Routines/ConsolidatedPlayerInput.s`
- Lines 140, 174, 193, 205: Writes to `player4Input_W` ($d063) which corrupts `eliminationEffectTimer_W`
- The routine uses player4Input_W but eliminationEffectTimer_W shares the same address

### File: `/home/brpocock/Projects/ChaosFight/Source/Routines/CheckPlayerElimination.s`
- Line 38: Documentation mentions `eliminationEffectTimer[]` but doesn't use it (typo in comment)

### File: `/home/brpocock/Projects/ChaosFight/Source/Routines/TriggerEliminationEffects.s`
- Line 53: `sta eliminationEffectTimer_W,x` writes to $d063 which corrupts `player4Input_W`

## Resolution Required

These variables MUST be given unique write and read port addresses to prevent:
1. Data corruption between related variables
2. Potential crashes when writing to read ports
3. Incorrect data being read back

The resolution should reassign unique SCRAM addresses to these conflicting variables.