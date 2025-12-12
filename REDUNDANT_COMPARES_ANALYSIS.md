# Redundant Compare-to-Zero Analysis

## Summary

Found **130 occurrences** of `cmp # 0`, `cpx # 0`, or `cpy # 0` that are redundant because the Z flag is already set by a previous operation.

## Operations That Set Z Flag

These operations set the Z flag, making a subsequent `cmp # 0` redundant:
- `lda` - Load Accumulator
- `and` - Logical AND
- `ora` - Logical OR
- `eor` - Exclusive OR
- `adc` - Add with Carry
- `sbc` - Subtract with Carry
- `asl`, `lsr`, `rol`, `ror` - Shift/Rotate operations
- `inc`, `dec` - Increment/Decrement
- `bit` - Bit Test
- `tax`, `tay`, `txa`, `tya`, `tsx`, `txs` - Transfer operations

## Pattern

**Redundant Pattern:**
```assembly
lda someValue
cmp # 0
beq SomeLabel
```

**Optimized:**
```assembly
lda someValue
beq SomeLabel
```

## Files with Redundant Compares

All 130 occurrences are redundant. Key files include:

- `Source/Routines/IsPlayerEliminated.s` - 1 occurrence
- `Source/Routines/InputHandleAllPlayers.s` - 6 occurrences
- `Source/Routines/PlayerInput.s` - 12 occurrences
- `Source/Routines/ConsoleHandling.s` - 5 occurrences
- `Source/Routines/BudgetedMissileCollisionCheck.s` - 1 occurrence
- `Source/Routines/HandlePauseInput.s` - 1 occurrence
- `Source/Routines/UpdateSingleGuardTimer.s` - 3 occurrences
- And many more...

## Benefits of Optimization

- **Saves 2 bytes** per redundant compare (cmp # 0 = 2 bytes)
- **Saves 2 cycles** per redundant compare (cmp # 0 = 2 cycles)
- **Total potential savings**: ~260 bytes and ~260 cycles across the codebase

## Analysis Tool

See `Tools/find-redundant-compares.sh` for the analysis script.
