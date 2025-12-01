# Corrected Stack Overflow Analysis - $5:fb63

## Critical Discovery: `on gosub` Stack Usage

Looking at `Tools/batariBASIC/statements.c:2997-3012`, `on gosub` actually pushes **4 bytes** temporarily, then `RTS` pops 2 bytes, leaving **2 bytes** on the stack (the return address).

However, the comment in `VblankHandlers.bas:25` says:
```
rem CRITICAL: on gameMode gosub is a NEAR call (pushes normal 2-byte return address)
```

This is **CORRECT** - `on gosub` is a near call that pushes 2 bytes (the return address).

## Corrected Call Chain Analysis

### Actual Call Chain (from debugger evidence)
1. **Kernel** → `VblankHandlerTrampoline` (jsr, **2 bytes**)
2. **VblankHandlerTrampoline** → `VblankHandlerDispatcher` (gosub bank11, **4 bytes**)
3. **VblankHandlerDispatcher** → `VblankModeTitleScreen` (on gosub, **2 bytes**) ✅ CORRECTED
4. **VblankModeTitleScreen** → `VblankSharedUpdateCharacterAnimations` (goto, **0 bytes**) ✅ FIXED
5. **VblankUpdateSprite_Bank5Dispatch** → `SetPlayerCharacterArtBank5 bank5` (gosub bank5, **4 bytes**)

**Calculated Total**: 2 + 4 + 2 + 0 + 4 = **12 bytes** (should be safe)

**Actual Stack Usage**: **17 bytes** (SP at `$ef`)

**Discrepancy**: **5 bytes unaccounted for**

## Possible Causes

### 1. Additional calls before reaching this point
- May be called from a deeper context
- Need to trace actual execution path from stack contents

### 2. `BS_return` or bank switching overhead
- `SetPlayerCharacterArtBank5` uses `jmp BS_return`
- `BS_return` may push additional bytes during bank switch decoding

### 3. Hidden `pha` instructions
- May have missed some `pha` instructions in the code
- Need to verify all assembly code paths

### 4. Different entry point
- May not be going through vblank handlers
- Could be called from a different path entirely

## Next Steps

1. **Trace actual stack contents**: Use debugger to examine stack at `$ef` and work backwards
2. **Check `BS_return` implementation**: Verify if it pushes any bytes during bank switch decoding
3. **Verify all `pha` instructions**: Search for any remaining `pha` in the call chain
4. **Check for other entry points**: Verify if sprite loading is called from other paths

## Key Insight

Since labels are bank-insensitive, the label `.CRTSMC_NextPlayer` at `fb63` doesn't tell us which bank we're in. The debugger shows Bank 5, so we need to identify what code is actually at `fb63` in Bank 5, not rely on the label name.

