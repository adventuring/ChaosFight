# Parameter Optimization Analysis

## Summary

This document identifies common parameters that are frequently passed between functions and would benefit from being moved to global variables instead. This optimization reduces `temp1-temp6` pressure and simplifies code patterns.

## Current State

### Existing Global Variables

- **`currentPlayer`** - Already defined and used in `AnimationSystem.bas`
  - Used as INPUT to many animation functions
  - Functions like `UpdatePlayerAnimation`, `GetCurrentAnimationFrame`, etc. use `currentPlayer` directly
  - **Pattern**: Set `currentPlayer = 0-3` before calling functions

### Frequent Parameter Patterns

1. **`playerIndex` / `playerID`** - 875 matches across 21 files
   - Most commonly passed as `temp1`
   - Used in loops: `for currentPlayer = 0 to 3` followed by `let temp1 = currentPlayer`
   
2. **`characterIndex` / `characterID`** - ~150 matches
   - Passed as `temp1` or `temp2`
   - Often derived from `playerChar[playerIndex]`

## Recommended Changes

### 1. Standardize `currentPlayer` Usage

**Current Pattern (inefficient)**:
```basic
for currentPlayer = 0 to 3
    let temp1 = currentPlayer
    gosub CheckPlayerElimination
next
```

**Recommended Pattern**:
```basic
for currentPlayer = 0 to 3
    gosub CheckPlayerElimination  ; Uses currentPlayer directly
next
```

**Functions to Update** (accept `currentPlayer` instead of `temp1`):
- `CheckPlayerElimination` (PlayerElimination.bas:60)
- `IsPlayerEliminated` (PlayerElimination.bas:204)
- `IsPlayerAlive` (PlayerElimination.bas:227)
- `GetPlayerPosition` (MovementSystem.bas:168)
- `GetPlayerVelocity` (MovementSystem.bas:181)
- `UpdatePlayerMovementSingle` (MovementSystem.bas:61)
- `CheckPlayfieldCollisionAllDirections` (GameLoopMain.bas:64-72)
- `CheckPlayerCollision` (MovementSystem.bas:241)
- `TriggerEliminationEffects` (PlayerElimination.bas:109)
- `DeactivatePlayerMissiles` (PlayerElimination.bas:157)
- And 50+ more functions...

**Benefits**:
- Eliminates `let temp1 = currentPlayer` in loops
- Reduces temp variable pressure
- More consistent with AnimationSystem pattern
- Clearer code intent

### 2. Add `currentCharacter` Global Variable

**Definition Location**: `Source/Common/Variables.bas`

**Usage Pattern**:
```basic
let currentCharacter = playerChar[currentPlayer]
gosub LoadCharacterSprite  ; Uses currentCharacter directly
```

**Functions That Would Benefit**:
- `LoadCharacterSprite` (SpriteLoader.bas:49)
- `ValidateCharacterIndex` (SpriteLoader.bas:74)
- `LoadCharacterColors` (SpriteLoader.bas:403)
- Character-specific functions that currently take `temp1 = characterIndex`

**Use Cases**:
1. In loops iterating players: `let currentCharacter = playerChar[currentPlayer]`
2. Character-specific attack logic
3. Character-specific movement logic
4. Sprite loading operations

**Benefits**:
- Reduces `temp1 = playerChar[currentPlayer]` patterns
- Clearer separation between player index and character type
- Enables character-specific logic without parameter passing

## Implementation Priority

### High Priority (Most Impact)

1. **Update PlayerElimination.bas functions**
   - `CheckPlayerElimination` - Called in loop
   - `IsPlayerEliminated` - Called in loop
   - `IsPlayerAlive` - Called in loop

2. **Update MovementSystem.bas functions**
   - `UpdatePlayerMovementSingle` - Called in loop
   - `GetPlayerPosition` - Called in loops
   - `GetPlayerVelocity` - Called in loops

3. **Update GameLoopMain.bas**
   - `CheckPlayfieldCollisionAllDirections` - Called in loop

### Medium Priority

4. **Update SpriteLoader.bas**
   - Add `currentCharacter` usage
   - `LoadCharacterSprite` - Character index passed frequently

5. **Update Character-specific functions**
   - Many take `characterIndex` as parameter
   - Would benefit from `currentCharacter`

### Low Priority (Consider for Future)

6. **Other systems**
   - Missile system functions
   - Guard effects functions
   - Fall damage functions

## Code Examples

### Example 1: PlayerElimination.bas

**Before**:
```basic
CheckAllPlayerEliminations
    for currentPlayer = 0 to 3
        let CPE_playerIndex = currentPlayer
        gosub CheckPlayerElimination
    next
```

**After**:
```basic
CheckAllPlayerEliminations
    for currentPlayer = 0 to 3
        gosub CheckPlayerElimination  ; Uses currentPlayer directly
    next

CheckPlayerElimination
    dim CPE_bitMask = temp6
    dim CPE_isEliminated = temp2
    dim CPE_health = temp2
    rem currentPlayer is already set (no parameter needed)
    let CPE_bitMask = BitMask[currentPlayer]
    ...
```

### Example 2: MovementSystem.bas

**Before**:
```basic
UpdatePlayerMovement
    let temp1 = 0
    gosub UpdatePlayerMovementSingle
    let temp1 = 1
    gosub UpdatePlayerMovementSingle
    ...
```

**After**:
```basic
UpdatePlayerMovement
    for currentPlayer = 0 to 3
        gosub UpdatePlayerMovementSingle  ; Uses currentPlayer directly
    next
```

### Example 3: Character Operations

**Before**:
```basic
for currentPlayer = 0 to 3
    let temp1 = playerChar[currentPlayer]
    let temp2 = 0
    gosub LoadCharacterSprite
next
```

**After**:
```basic
for currentPlayer = 0 to 3
    let currentCharacter = playerChar[currentPlayer]
    let temp2 = 0
    gosub LoadCharacterSprite  ; Uses currentCharacter directly
next
```

## Variable Memory Allocation

### `currentPlayer`
- **Location**: Already exists, but verify it's in appropriate memory location
- **Size**: 1 byte (0-3)
- **Scope**: Global (used across many routines)

### `currentCharacter` (NEW)
- **Location**: `Source/Common/Variables.bas`
- **Suggested**: Use a common variable (e.g., `var47` or SCRAM)
- **Size**: 1 byte (0-31)
- **Scope**: Global (used across many routines)

## Migration Strategy

1. **Phase 1**: Update function signatures to use `currentPlayer` instead of `temp1`
   - Start with most frequently called functions
   - Update callers to remove `let temp1 = currentPlayer`

2. **Phase 2**: Add `currentCharacter` variable
   - Define in Variables.bas
   - Update character-specific functions

3. **Phase 3**: Update remaining functions
   - Gradually migrate other systems
   - Update documentation

## Testing Considerations

- Ensure `currentPlayer` is set correctly before each function call
- Verify `currentCharacter` is set when needed
- Test all player loops to ensure correct behavior
- Verify no functions accidentally use stale values

## Related Issues

- Reduces temp variable pressure (Addresses temp1-temp6 usage)
- Improves code consistency (Matches AnimationSystem pattern)
- Simplifies function signatures (Fewer parameters to pass)

