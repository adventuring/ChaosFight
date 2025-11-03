# Complex Issues Breakdown - All Issues Now Trivial

**Date**: Generated from complex issue analysis  
**Parent Issues**: #336, #431, #429, #434 (from #445)

All complex issues have been broken down into trivial sub-issues that can be implemented independently.

---

## Issue #336: CRITICAL ROM Build Problem

**Root Cause**: Build fails due to BASIC syntax errors + incorrect bankswitch hotspot

### Sub-Issues Created:

1. **#446**: Fix bankswitch hotspot: $FFF8 to $1FE0 for EFSC
   - **Trivial**: Change 3 lines in AssemblyConfig files
   - **Files**: AssemblyConfig.NTSC.s, AssemblyConfig.PAL.s, AssemblyConfig.SECAM.s
   - **Fix**: `bankswitch_hotspot = $1FE0` (was $FFF8)

2. **#447**: Fix BASIC syntax errors blocking ROM build
   - **Trivial**: Run build, categorize errors, fix systematically
   - **Strategy**: Fix most common errors first (likely missing LET)
   - **Files**: All .bas files

---

## Issue #431: Missing 'let' Keyword on Variable Assignments

**Requirement**: Use LET for all user variables (not system variables)

### Sub-Issues Created (3-step process):

1. **#449**: Add LET keyword: Identify all user variable assignments
   - **Trivial**: Create grep pattern, filter system variables, document list
   - **Output**: Comment with user variables needing LET

2. **#450**: Add LET keyword: Create automated fix script
   - **Trivial**: Write script to insert LET before user variables
   - **Prerequisites**: #449 (user variable list)

3. **#451**: Add LET keyword: Apply fixes to all files
   - **Trivial**: Run script, verify, fix any regressions
   - **Prerequisites**: #450 (script)

---

## Issue #429: Labels should be PascalCase

**Requirement**: Convert user-defined labels to PascalCase (preserve keywords)

### Sub-Issues Created (3-step process):

1. **#452**: Labels PascalCase: Identify batariBASIC keywords
   - **Trivial**: Document complete keyword list from compiler source
   - **Output**: Comment with all keywords to preserve

2. **#453**: Labels PascalCase: Find all non-keyword labels
   - **Trivial**: Grep for labels, filter keywords, document user labels
   - **Prerequisites**: #452 (keyword list)

3. **#454**: Labels PascalCase: Convert to PascalCase
   - **Trivial**: Convert labels and update all goto/gosub references
   - **Prerequisites**: #453 (label list)

---

## Issue #434: Missing Tail Call Optimizations

**Requirement**: Convert same-bank tail calls (gosub+return → goto)

### Sub-Issues Created (3-step process):

1. **#455**: Tail call optimization: Identify bank-crossing calls
   - **Trivial**: Find all `gosub bankN` patterns, create exclusion list
   - **Output**: Comment with bank-crossing calls (cannot optimize)

2. **#456**: Tail call optimization: Find same-bank tail calls
   - **Trivial**: Find `gosub` followed by `return`, exclude bank-crossing
   - **Prerequisites**: #455 (exclusion list)

3. **#457**: Tail call optimization: Convert to goto
   - **Trivial**: Replace `gosub FunctionName` + `return` with `goto FunctionName`
   - **Prerequisites**: #456 (optimizable calls)

---

## Summary

**Total Sub-Issues Created**: 11

- **ROM Build (#336)**: 2 sub-issues (#446, #447)
- **LET Keyword (#431)**: 3 sub-issues (#449, #450, #451)
- **Labels PascalCase (#429)**: 3 sub-issues (#452, #453, #454)
- **Tail Calls (#434)**: 3 sub-issues (#455, #456, #457)

**All Issues**: Now trivial with clear, actionable steps

---

## Implementation Order Recommendation

1. **Critical First**: #446, #447 (ROM build blocker)
2. **Code Quality**: #449 → #450 → #451 (LET keyword chain)
3. **Code Quality**: #452 → #453 → #454 (Labels chain)
4. **Optimization**: #455 → #456 → #457 (Tail calls chain)

Each sub-issue can be completed independently within its chain.

