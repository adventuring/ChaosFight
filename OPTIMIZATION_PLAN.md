# Optimization Plan for Remaining Open Issues

## High Priority Optimizations

### #1188: Optimize Bank 7 MissileSystem (1363 → <900 bytes)
**Current Size:** 1363 bytes  
**Target:** <900 bytes  
**Savings Needed:** ~463 bytes

#### Optimization Opportunities Identified:

1. **Character-Specific Hooks (Estimated: ~150 bytes)**
   - Megax handler: ~85 bytes (stationary missile)
   - Knight Guy handler: ~165 bytes (sword swing animation)
   - Harpy dive checks: ~30 bytes (scattered)
   - **Strategy:** Create dispatch table indexed by character ID
   - **Savings:** Consolidate character checks into single table lookup

2. **Duplicated Lifetime/Physics Branches (Estimated: ~200 bytes)**
   - Lifetime decrement logic duplicated
   - Gravity application: simple but could be table-driven
   - Friction calculation: complex bit-shift logic duplicated
   - **Strategy:** Extract shared physics routines, use flags for branching
   - **Savings:** Remove duplicate code paths

3. **Table-Driven State Machine (Estimated: ~100 bytes)**
   - Missile flags currently checked with bitwise operations
   - Physics application (gravity, friction, bounce) scattered
   - **Strategy:** Create state table mapping flags → handler addresses
   - **Savings:** Replace if-chain with table lookup

4. **Code Consolidation (Estimated: ~50 bytes)**
   - Position update logic duplicated
   - Boundary checking duplicated
   - Collision check setup duplicated
   - **Strategy:** Extract common patterns into shared helpers
   - **Savings:** Reduce code duplication

#### Implementation Steps:
1. Extract shared physics routines (gravity, friction, lifetime)
2. Create character handler dispatch table
3. Create flag-based state machine table
4. Consolidate position/boundary update code
5. Verify size reduction and functionality

---

### #1152: Consolidate roboTitoCanStretch and harpyFlightEnergy
**Savings:** 4 bytes SCRAM  
**Priority:** Medium (quick win)

**Implementation:**
- Create `characterSpecialAbility[0-3]` array (4 bytes, w089-w092)
- Robo Tito: stores stretch permission flags (bit-packed)
- Harpy: stores flight energy (byte per player)
- Replace all `roboTitoCanStretch` references
- Replace all `harpyFlightEnergy` references
- Verify no conflicts (never active simultaneously)

---

### #1142: Optimize SetSpritePositions ROM footprint
**Current:** 476 bytes in Bank 6  
**Target:** Reduce by ~100-150 bytes

**Opportunities:**
- Consolidate sprite position calculation loops
- Extract common rendering patterns
- Optimize missile rendering code

---

### #1141: Split PlayerPhysicsCollisions into focused modules
**Strategy:**
- Extract boundary collision logic
- Extract playfield collision logic
- Extract player-player collision logic
- Each module in appropriate bank

---

### #1140: Optimize MissileSystem for modularity and ROM savings
**Note:** Overlaps with #1188, but focuses on modularity

---

### #1139: Trim Character Select Render ROM usage
**Current:** 702 bytes in Bank 6  
**Target:** Reduce by ~150-200 bytes

**Opportunities:**
- Optimize rendering loops
- Consolidate glyph rendering
- Extract common UI patterns

---

### #1138: Retire dead Physics module stub
**Action:** Remove unused stub code

---

### #1136: Combine SetPlayerGlyphFromFont.bas and CopyGlyphToPlayer.bas
**Strategy:**
- Analyze both routines
- Identify shared logic
- Create unified routine
- Update call sites

---

### #1128: Analyze small subroutines for inlining opportunities
**Strategy:**
- Identify routines <20 bytes that are far-called
- Inline at call sites
- Remove far-call overhead

---

### #588: Find same-bank tail calls eligible for goto conversion
**Strategy:**
- Scan for `gosub` calls within same bank
- Convert to `goto` where appropriate
- Save return stack overhead

---

## Medium Priority Enhancements

### #1103: Fix pfscorebars for four players
**Status:** Players 3 & 4 health bars not implemented
**Strategy:**
- Review HealthBarSystem.bas
- Implement P3/P4 rendering (may need playfield graphics)
- Update FrameBudgeting.bas

---

## Low Priority (Unplanned Enhancements)

- #1180: Ursulo uppercut knock-up scaling
- #1179: Rebalance bank layouts
- #1178: Bernie post-fall stun animation
- #1177: Frooty lollipop charge-and-bounce attack
- #869, #762, #747: Visual enhancements
- #660, #659: Documentation
- #601: Verify PAL color palette
- #331: Custom font for score
- #272: AI difficulty
- #215: Per-character sound fonts
- #189-183: CPU player controllers
- #575-563: Music placeholder replacements

---

## Code Quality Improvements

### #1154: Rename UpdateMusic to PlayMusic
**Priority:** Low  
**Impact:** Naming clarity only

**Files to update:**
- Source/Routines/MusicSystem.bas
- Source/Routines/MainLoop.bas
- Source/Routines/PublisherPrelude.bas
- Source/Routines/AuthorPrelude.bas
- Comments in MusicBankHelpers*.bas

---

## Next Steps

1. **Immediate:** Work on #1188 (MissileSystem optimization)
2. **Quick Win:** #1152 (SCRAM consolidation)
3. **Follow-up:** #1142, #1141, #1140 (ROM optimizations)
4. **Polish:** #1139, #1138, #1136, #1128, #588 (code quality)

