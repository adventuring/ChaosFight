# Stack Overflow Analysis - Complete Review

## Stack Limit
- **Atari 2600 Stack**: 16 bytes ($F0-$FF)
- **Stack Pointer**: Starts at $FF, grows downward
- **Overflow**: SP < $F0

## Stack Usage by Call Type
- **Near call (jsr/gosub same bank)**: 2 bytes
- **Cross-bank call (gosub bankX)**: 4 bytes
  - 2 bytes for stub jsr
  - 2 bytes for target jsr (after bank switch)
- **on gosub**: 4 bytes
  - 2 bytes for return address (ongosub0)
  - 2 bytes for target address (from jump table)
- **pha instruction**: 1 byte per push

## Critical Call Chains

### 1. VblankHandlerDispatcher → VblankModeGameMain → SetPlayerCharacterArtBank5
**Status**: ✅ FIXED (14 bytes)

**Call Chain**:
1. Kernel → VblankHandlerTrampoline (jsr, 2 bytes)
2. VblankHandlerTrampoline → VblankHandlerDispatcher (gosub bank11, 4 bytes)
3. VblankHandlerDispatcher → VblankModeGameMain (on gosub, 4 bytes)
4. VblankModeGameMain → VblankUpdateSprite (goto, 0 bytes) - inlined UpdateCharacterAnimations
5. VblankUpdateSprite → SetPlayerCharacterArtBank5 (gosub bank5, 4 bytes)

**Total**: 2 + 4 + 4 + 0 + 4 = **14 bytes** ✅

### 2. MainLoop → GameMainLoop → Various Routines
**Status**: ⚠️ NEEDS REVIEW

**Call Chain**:
1. Kernel → MainLoop (jsr, 2 bytes) - or is this a cross-bank call?
2. MainLoop → MainLoopModeGameMain (on gosub, 4 bytes)
3. MainLoopModeGameMain → GameMainLoop (gosub bank11, 4 bytes)
4. GameMainLoop → [various routines]

**Potential Deep Chains from GameMainLoop**:
- GameMainLoop → InputHandleAllPlayers (gosub bank8, 4 bytes)
  - InputHandleAllPlayers → [character-specific input handlers]
- GameMainLoop → UpdateSoundEffect (gosub bank15, 4 bytes)
  - UpdateSoundEffect → [sound effect routines]

**Current Depth**: 2 + 4 + 4 = 10 bytes (before any GameMainLoop calls)
**Remaining Budget**: 6 bytes

### 3. VblankModeGameMain → HandleAnimationTransition
**Status**: ⚠️ NEEDS REVIEW

**Call Chain** (from VblankModeGameMain):
1. [Already at 14 bytes from entry]
2. VblankModeGameMain → HandleAnimationTransition (gosub bank12, 4 bytes)

**Total if called**: 14 + 4 = **18 bytes** ❌ OVERFLOW!

**Fix**: HandleAnimationTransition is only called from VblankHandleFrame7Transition, which is inside the inlined UpdateCharacterAnimations loop. Need to verify this doesn't exceed stack.

### 4. VblankModeGameMain → Other Routines
**Status**: ⚠️ NEEDS REVIEW

After the inlined animation code, VblankModeGameMain calls:
- UpdatePlayerMovement (gosub bank8, 4 bytes)
- PhysicsApplyGravity (gosub bank13, 4 bytes)
- ApplyMomentumAndRecovery (gosub bank8, 4 bytes)
- CheckBoundaryCollisions (gosub bank10, 4 bytes)
- CheckPlayfieldCollisionAllDirections (gosub bank10, 4 bytes)
- CheckAllPlayerCollisions (gosub bank11, 4 bytes)
- ProcessAllAttacks (gosub bank7, 4 bytes)
- CheckAllPlayerEliminations (gosub bank14, 4 bytes)
- UpdateAllMissiles (gosub bank7, 4 bytes)
- CheckRoboTitoStretchMissileCollisions (gosub bank10, 4 bytes)
- SetPlayerSprites (gosub bank6, 4 bytes)
- DisplayHealth (gosub bank11, 4 bytes)
- UpdatePlayer12HealthBars (gosub bank11, 4 bytes)
- UpdatePlayer34HealthBars (gosub bank11, 4 bytes)

**Current Stack Depth**: 14 bytes (from entry to VblankModeGameMain)
**Each Additional Call**: +4 bytes
**Maximum Additional**: 4 bytes (to reach 16-byte limit)

**Problem**: These are sequential calls, not nested, so stack should unwind between calls. But need to verify each individual call chain doesn't exceed 16 bytes.

## Files with pha Instructions
- Source/Routines/CharacterArtBank5.s (removed, but check others)
- Source/Routines/CharacterArtBank2.s
- Source/Routines/CharacterArtBank3.s
- Source/Routines/CharacterArtBank4.s
- Source/Common/BankSwitching.s (BS_return uses pha)

## Critical Issues Found

### ❌ Issue 1: HandleAnimationTransition Stack Overflow
**Location**: `Source/Routines/VblankHandlers.bas:130`

**Problem**: 
- Called from within inlined UpdateCharacterAnimations at 14 bytes depth
- `gosub HandleAnimationTransition bank12` adds 4 bytes
- **Total: 18 bytes** ❌ EXCEEDS 16-byte limit

**Call Chain**:
1. Kernel → VblankHandlerTrampoline (2 bytes)
2. VblankHandlerTrampoline → VblankHandlerDispatcher (4 bytes)
3. VblankHandlerDispatcher → VblankModeGameMain (4 bytes)
4. VblankModeGameMain → VblankHandleFrame7Transition (0 bytes, goto)
5. VblankHandleFrame7Transition → HandleAnimationTransition (4 bytes) ❌

**Fix Required**: 
- Option 1: Inline HandleAnimationTransition into VblankHandleFrame7Transition
- Option 2: Restructure to avoid calling from deep in call chain
- Option 3: Move HandleAnimationTransition to same bank as VblankModeGameMain (bank11) to make it a near call (2 bytes instead of 4)

### ❌ Issue 2: CharacterArtBank2, 3, 4 Stack Overflow
**Locations**: 
- `Source/Routines/CharacterArtBank2.s:145,156`
- `Source/Routines/CharacterArtBank3.s:145,156`
- `Source/Routines/CharacterArtBank4.s:144,155`

**Problem**: 
- These routines use `pha` to save player number (1 byte)
- Called from VblankUpdateSprite at 14 bytes depth
- `gosub SetPlayerCharacterArtBankX bankX` adds 4 bytes
- `pha` adds 1 byte
- **Total: 19 bytes** ❌ EXCEEDS 16-byte limit

**Fix Required**: Apply same optimization as Bank5:
- Use X register or temp6 to save player number instead of stack
- Remove all `pha`/`pla` instructions

### ⚠️ Issue 3: Other VblankModeGameMain Calls
**Status**: Need to verify each individual call doesn't exceed 16 bytes

After inlined animation code (at 14 bytes depth), VblankModeGameMain makes sequential calls:
- These are sequential (not nested), so stack unwinds between calls
- Each call should be safe if it doesn't exceed 2 bytes additional depth
- Need to verify each routine's internal call chain

## Recommendations

1. **URGENT: Fix HandleAnimationTransition** - Move to bank11 or inline
2. **URGENT: Fix CharacterArtBank2, 3, 4** - Remove pha instructions
3. **Review all VblankModeGameMain sequential calls** - Verify each is safe
4. **Review GameMainLoop call chains** - Ensure no deep nesting
5. **Check all on gosub usage** - Verify all are accounted for as 4 bytes
6. **Review any recursive calls** - Ensure no infinite recursion

