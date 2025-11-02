# Phase 1 Implementation Plan: Titlescreen Kernel Integration

## Current Status

### ✅ Completed
- Titlescreen kernel copied to `Source/Titlescreen/`
- Layout configured for three 48x2 minikernels
- Screen routines updated to use `titledrawscreen bank1`
- Bitmap art generator (`compile-batari-48px`) implemented in SkylineTool
- Art.*.s files generated from PNG sources
- Makefile dependencies configured for bitmap generation
- Assembly includes wrapped in `asm`/`end` blocks in Bank1.bas
- Preprocessor directives fixed (`ifconst`/`endif` instead of `#ifconst`/`#endif`)
- ColGray alias added to Colors.h
- Apostrophes removed from remarks/comments (ongoing)

### ⏳ In Progress / Blocking Issues

#### 1. ROM Build Failure (CRITICAL)
**Problem**: ROM files are only 1276 bytes (filled with 0xFF) instead of 65536 bytes.

**Symptoms**:
- DASM completes with exit code 0 ("Complete. (0)")
- ROM file exists but only contains filler bytes
- Listing files generated (3656 lines) but may be incomplete
- Assembly source file may not be generated properly

**Root Cause Analysis Needed**:
- [ ] Verify `Source/Generated/ChaosFight.NTSC.s` is actually generated
- [ ] Check if batariBASIC compilation is producing valid assembly
- [ ] Verify DASM is receiving valid input (not empty or malformed)
- [ ] Check for silent errors in postprocessing/optimization pipeline
- [ ] Verify bankswitching configuration (64kSC = 65536 bytes)

**Investigation Steps**:
1. Trace build pipeline: preprocess → 2600basic → postprocess → optimize → dasm
2. Check each intermediate file for errors or empty content
3. Verify Makefile dependency chain executes all steps
4. Check for missing or incorrect include paths

#### 2. Manual Generation Failure
**Problem**: Texinfo compilation fails with syntax error at line 201.

**Error**: `Emergency stop. @badenverr ...temp , not @inenvironment @thisenv }`

**Root Cause**: Mismatched Texinfo block structure:
- Line 192: `@itemize @bullet` starts itemize block
- Line 201: `@end table` closes wrong block type (should be `@end itemize`)

**Fix Required**:
- [ ] Change line 201 from `@end table` to `@end itemize`
- [ ] Verify all `@table`/`@end table` and `@itemize`/`@end itemize` pairs are matched

#### 3. SECAM Build Missing AssemblyConfig
**Problem**: SECAM build fails with "No rule to make target 'Source/Common/AssemblyConfig.SECAM.s'"

**Fix Required**:
- [ ] Create `Source/Common/AssemblyConfig.SECAM.s` or fix Makefile dependency
- [ ] Verify SECAM-specific assembly configuration exists

## Phase 1 Success Criteria

- [x] All three Art.*.s files generated (AtariAge, Interworldly, ChaosFight)
- [x] Titlescreen kernel integrated in Bank 1
- [x] Screen routines call `titledrawscreen bank1`
- [ ] **All three .a26 files compile successfully**
- [ ] **All three .a26 files are exactly 65536 bytes**
- [ ] **All three .lst files are complete (verify content, not just line count)**
- [ ] **Manual PDF and HTML files generated successfully**

## Phase 2: Remaining Tasks (Blocked by Phase 1)

### Bug Fixes
- [ ] Replace hardcoded animation action values with enum constants (#30)
- [ ] Fix LoadSpecialSpriteData function issues (#296, #10455870)
- [ ] Review r/w SuperChip RAM variable usage (#31)
- [ ] Fix JSR/JMP address errors in Bank 9 (#32)

### Features
- [ ] Implement Shamone's special attack (jump on attack)
- [ ] Implement Shamone's form switching (Up converts to MethHound)
- [ ] Test Bernie fall-through ability (#29)
- [ ] Ensure Zoe Ryen naming consistency (#318)
- [ ] Ensure Shamone naming consistency (#319)

### Testing
- [ ] Test all character special abilities
- [ ] Verify 4-player functionality
- [ ] Test controller detection
- [ ] Verify all TV standards (NTSC, PAL, SECAM)

## Implementation Steps

### Step 1: Fix ROM Build Failure
1. Clean build environment
2. Run build with verbose output to trace pipeline
3. Inspect intermediate files (preprocessed.bas, bB.asm, optimized assembly)
4. Identify where assembly generation fails
5. Fix root cause (likely in batariBASIC compilation or postprocessing)
6. Verify ROM size is 65536 bytes
7. Verify ROM content is valid (not all 0xFF)

### Step 2: Fix Manual Generation
1. Fix Texinfo syntax error (line 201: `@end table` → `@end itemize`)
2. Verify all Texinfo block structures are correct
3. Test PDF generation: `make Dist/ChaosFight.pdf`
4. Test HTML generation: `make Dist/ChaosFight.html`
5. Verify output files are non-empty and valid

### Step 3: Fix SECAM Build
1. Check if `AssemblyConfig.SECAM.s` should exist
2. Check Makefile dependencies for SECAM build
3. Create missing file or fix dependency chain
4. Verify SECAM ROM builds successfully

### Step 4: Verify Phase 1 Complete
1. Build all three ROM variants (NTSC, PAL, SECAM)
2. Verify all ROM files are 65536 bytes
3. Verify all listing files contain valid assembly
4. Verify manual files are generated
5. Update GitHub issue #320 with completion status

## Notes

- ROM size issue is critical blocker - all other Phase 1 tasks depend on successful compilation
- Manual generation is separate issue but required for Phase 1 success criteria
- Phase 2 tasks are documented but blocked until Phase 1 is complete

