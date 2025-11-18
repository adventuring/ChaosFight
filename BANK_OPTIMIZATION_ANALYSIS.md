# Bank Overflow Optimization Analysis

## Current Status
- ✅ **Fixed Banks**: 6, 7, 8, 9, 10, 11, 13
- ❌ **Overflowing Banks**: 12 (3809 bytes, needs ~200 bytes), 14 (4840 bytes, needs ~840 bytes)

## Option 1: Code Optimization

### Largest Routines (by line count)
1. **MissileSystem.bas**: 1196 lines (in Bank 10 - 3643 bytes, OK)
2. **PlayerInput.bas**: 1158 lines
3. **CharacterControlsJump.bas**: 857 lines
4. **PlayerPhysicsCollisions.bas**: 583 lines (in Bank 14 - causing overflow)
5. **AnimationSystem.bas**: 563 lines (in Bank 12 - causing overflow)
6. **Combat.bas**: 518 lines (in Bank 14 - causing overflow)
7. **ArenaSelect.bas**: 403 lines (in Bank 12 - OK)

### Optimization Opportunities

#### A. MissileSystem.bas (1196 lines)
**Current Location**: Bank 10 (3643 bytes - OK)
**Functions**: 
- `GetPlayerMissileBitFlag` (small)
- `SpawnMissile` (large)
- `UpdateAllMissiles` (small - loops)
- `UpdateOneMissile` (very large - ~400 lines)
- Character-specific handlers (Harpy, Knight Guy, Megax, etc.)

**Optimization Potential**:
- Character-specific missile handlers could be moved to character-specific banks
- Inline assembly optimizations for bit operations
- Reduce duplicate code in character handlers

**Estimated Savings**: 200-400 bytes if character handlers moved

#### B. PlayerPhysicsCollisions.bas (583 lines)
**Current Location**: Bank 14 (4840 bytes - OVERFLOW)
**Functions**:
- `CheckBoundaryCollisions` (large - handles all 4 players with duplication)
- `CheckPlayfieldCollisionAllDirections` (large)

**Optimization Potential**:
- **CRITICAL**: Player boundary checks are duplicated 4 times (P0, P1, P2, P3)
- Could extract common boundary check logic into shared function
- Playfield collision has inline divide-by-8 that could be optimized

**Estimated Savings**: 300-500 bytes from deduplication

#### C. AnimationSystem.bas (563 lines)
**Current Location**: Bank 12 (3809 bytes - OVERFLOW)
**Functions**:
- `UpdateCharacterAnimations` (small - loops)
- `UpdatePlayerAnimation` (large)
- `SetPlayerAnimation` (large)
- Multiple helper functions

**Optimization Potential**:
- Some helper functions could be inlined
- Reduce redundant state checks
- Optimize animation frame calculations

**Estimated Savings**: 100-200 bytes

#### D. Combat.bas (518 lines)
**Current Location**: Bank 14 (4840 bytes - OVERFLOW)
**Functions**: Need to analyze structure

**Optimization Potential**: TBD after analysis

**Estimated Savings**: TBD

## Option 2: Split Large Routines

### Splitting Strategy

#### A. MissileSystem.bas → Split into:
1. **MissileSystemCore.bas** (~400 lines)
   - `GetPlayerMissileBitFlag`
   - `SpawnMissile`
   - `UpdateAllMissiles`
   - `UpdateOneMissile` (core movement/physics)
   - **Location**: Keep in Bank 10

2. **MissileSystemCollisions.bas** (~300 lines)
   - Collision detection logic
   - Damage application
   - **Location**: Move to Bank 12 or 13

3. **MissileSystemCharacterHandlers.bas** (~500 lines)
   - Character-specific missile handlers (Harpy, Knight Guy, Megax, etc.)
   - **Location**: Move to character-specific banks or Bank 14

**Estimated Savings**: 800-1000 bytes from Bank 10, redistributed

#### B. PlayerPhysicsCollisions.bas → Split into:
1. **PlayerBoundaryCollisions.bas** (~200 lines)
   - `CheckBoundaryCollisions` (deduplicated version)
   - **Location**: Bank 13 (has space - 3639 bytes)

2. **PlayerPlayfieldCollisions.bas** (~380 lines)
   - `CheckPlayfieldCollisionAllDirections`
   - **Location**: Bank 14 (replace full file)

**Estimated Savings**: 200-300 bytes from deduplication + better distribution

#### C. AnimationSystem.bas → Split into:
1. **AnimationSystemCore.bas** (~300 lines)
   - `UpdateCharacterAnimations`
   - `UpdatePlayerAnimation` (core logic)
   - **Location**: Bank 12

2. **AnimationSystemHelpers.bas** (~260 lines)
   - `SetPlayerAnimation`
   - Helper functions (`IsPlayerWalking`, `IsPlayerAttacking`, etc.)
   - **Location**: Bank 11 or 13

**Estimated Savings**: Better distribution, minimal size reduction

#### D. Combat.bas → Split into:
1. **CombatCore.bas** (~300 lines)
   - Main combat loop
   - **Location**: Bank 14

2. **CombatHelpers.bas** (~218 lines)
   - Helper functions
   - **Location**: Bank 12 or 13

**Estimated Savings**: Better distribution

## Recommended Approach

### Phase 1: Quick Wins (Option 1)
1. **Deduplicate PlayerPhysicsCollisions.bas** boundary checks
   - Extract common boundary logic
   - **Savings**: ~300-400 bytes
   - **Impact**: Fixes Bank 14 overflow

2. **Optimize AnimationSystem.bas** helpers
   - Inline small helpers
   - **Savings**: ~100-150 bytes
   - **Impact**: May fix Bank 12 overflow

### Phase 2: Structural Changes (Option 2)
1. **Split MissileSystem.bas** character handlers
   - Move character-specific code to appropriate banks
   - **Savings**: ~500-800 bytes from Bank 10
   - **Impact**: Frees space for redistribution

2. **Split PlayerPhysicsCollisions.bas**
   - Separate boundary and playfield collisions
   - **Savings**: Better distribution + 200-300 bytes from deduplication

## Estimated Total Savings
- **Option 1 (Optimization)**: 400-600 bytes
- **Option 2 (Splitting)**: 1000-1500 bytes (with redistribution)
- **Combined**: 1400-2100 bytes

## Priority Actions
1. **IMMEDIATE**: Deduplicate PlayerPhysicsCollisions.bas boundary checks (fixes Bank 14)
2. **HIGH**: Optimize AnimationSystem.bas (may fix Bank 12)
3. **MEDIUM**: Split MissileSystem.bas character handlers (frees space)
4. **LOW**: Split other routines for better organization

