# Code Inefficiency Audit - Issue #151

**Status**: Future Enhancement  
**Priority**: After core build issues are resolved  
**Date**: 2025-01-XX

## Scope

Review all code to identify and remove obvious inefficiencies:
- Unnecessary gotos/gosubs/returns (redundant jumps, double-jumps)
- Assignments to variables never read (and not kernel/hardware registers)
- Redundant recomputation of the same value within tight loops
- Dead labels never targeted
- No-op sequences (e.g., set X then immediately overwrite)
- Inefficient multi-branch sequences that can short-circuit earlier

## Audit Results

### Dead Labels

**Note**: Many "dead" labels may be false positives:
- Entry points called via `gosub bankN LabelName` (not detected by simple grep)
- Data table markers used in lookups (not targeted by goto/gosub)
- Labels used in `on gameMode goto` statements
- Labels used in conditional branches via `then LabelName`

**Files with potential dead labels** (55 files, ~600+ labels):
- See automated audit output above for full list

**Key files to review manually**:
1. `AnimationSystem.bas` - 45 potential dead labels
2. `ArenaLoader.bas` - 65 potential dead labels  
3. `CharacterSelectMain.bas` - 65 potential dead labels
4. `CharacterControls.bas` - 38 potential dead labels
5. `Combat.bas` - 14 potential dead labels
6. `PlayerInput.bas` - 39 potential dead labels
7. `MissileSystem.bas` - 23 potential dead labels

### Redundant Jumps

**Pattern**: `goto Label` immediately followed by `Label: return`

**Potential instances found**: 0 (requires manual verification)

### Double Jumps

**Pattern**: `goto Label1` -> `Label1: goto Label2`

**Potential instances found**: 0 (requires manual verification)

### No-op Assignments

**Pattern**: Variable assigned then immediately overwritten

**Requires manual review** - simple patterns:
- Consecutive assignments to same variable
- Assignment followed immediately by different assignment to same variable

### Redundant Recomputations

**Pattern**: Same calculation performed multiple times in tight loops

**Requires manual review** - look for:
- Repeated array lookups: `CharacterWeights[temp1]` computed multiple times
- Repeated bit operations: `playerState[i] & Mask` computed multiple times
- Repeated function calls: `GetCharacterDamage` called multiple times with same input

## Checklist Per File

### High Priority (Most Frequently Called)

- [ ] `GameLoopMain.bas` - Main game loop (60fps)
- [ ] `PlayerInput.bas` - Input processing (60fps)
- [ ] `PlayerPhysics.bas` - Physics calculations (60fps)
- [ ] `MissileSystem.bas` - Missile updates (60fps)
- [ ] `Combat.bas` - Combat calculations (event-driven)
- [ ] `AnimationSystem.bas` - Animation updates (10fps)

### Medium Priority

- [ ] `CharacterControls.bas` - Character-specific movement
- [ ] `PlayerRendering.bas` - Sprite rendering
- [ ] `FrameBudgeting.bas` - Frame budget management
- [ ] `HealthBarSystem.bas` - Health bar updates

### Low Priority (Rarely Called)

- [ ] Admin mode screens (title, character select, etc.)
- [ ] Initialization routines
- [ ] Data loading routines

## Verification Notes

**Important**: Before removing any "dead" label:
1. Check if called via `gosub bankN LabelName`
2. Check if used in `on variable goto` statements
3. Check if used in data table lookups
4. Check if used in conditional branches: `if condition then LabelName`
5. Check if label is assembly entry point

**Safe to remove**:
- Labels that are truly never referenced
- Labels that are only targets of unreachable code
- Redundant intermediate labels in linear code paths

## Next Steps

1. **Manual verification** of high-priority files
2. **Profile code** to identify hot paths (60fps loops)
3. **Focus optimization** on frequently-called routines
4. **Document timing requirements** - some "inefficiencies" may be intentional for timing/kernel interaction

## References

- StyleGuide.md: Tail Call Optimization section
- Requirements.md: Performance requirements
- Issue #589: Tail call optimization (already completed)

