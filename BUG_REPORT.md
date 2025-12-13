# Bug Report - ChaosFight
Generated: 2025-12-13

## Summary
This report documents all remaining bugs in the codebase, excluding CPU player implementation issues.

---

## GitHub Issues (Open Bugs)

### #1323: Crash at $3:ffe4 - execution jumped into EFSC header area
**Status:** OPEN  
**Priority:** CRITICAL  
**Location:** Bank 3, address $ffe4 (EFSC header area)

**Description:**
Execution jumped into the EFSC identification header area. PC = $3:ffe4, which is the null byte after "EFSC" string (data, not code).

**Analysis:**
- $ffe0-$ffe3: "EFSC" header ($45, $46, $53, $43)
- $ffe4: 0 (null terminator) - **This is where execution jumped**
- Execution should never reach $ffe4 as it's data, not code

**Possible Causes:**
1. Corrupted return address on stack causing BS_return to decode bad address
2. Stack corruption leading to RTS jumping to $ffe4
3. Issue with BS_return decoding logic when stack contains invalid data

**Required for Debugging:**
- Stack pointer value when crash occurred
- Stack contents (top 4-8 bytes)
- Routine executing before crash
- Whether crash occurred after BS_return call

**Related:** Issue #1246

---

### #1314: Stack pointer corrupted: SP = $32 before Startup.s txs
**Status:** OPEN  
**Priority:** CRITICAL  
**Location:** Startup.s initialization

**Description:**
Stack pointer is corrupted (SP = $32 instead of expected value) when Startup.s tries to initialize it.

**Code Path:**
Reset → Bank 13 → ColdStart → ConsoleDetection.s → Startup.s

**Possible Causes:**
1. Something between Reset and Startup.s corrupting SP
2. Bank switch might affect SP (unlikely)
3. ConsoleDetection.s using stack (code review shows no stack usage)
4. Detection loop affecting SP somehow

**Required for Debugging:**
- Verify Reset handler actually executes
- Check if bank switch affects SP
- Verify no stack operations between Reset and Startup.s

---

### #1246: Write to read port: $378d at $3:ffe4
**Status:** OPEN  
**Priority:** HIGH  
**Location:** Bank 3

**Description:**
Reported write to read port at file offset $378d (Bank 3 CPU $F78D) from location $3:ffe4.

**Investigation:**
- File offset $378D is all zeros (padding/uninitialized)
- Bank 3 CPU $FFE4 is in EFSC header area (data, not code)
- No STA instructions found in listing writing to SCRAM read ports ($F080-$F0FF)

**Possible Interpretations:**
- Code at Bank 3 CPU $FFE4 writing to file offset $378D (CPU $F78D) - but $F78D is not a valid SCRAM address
- Code at file offset $378D writing to a read port - but $378D is padding
- Typo: maybe meant $F08D (r013) instead of $F78D?

**Required for Debugging:**
- Full debugger/emulator trace
- Operation being performed when this occurred
- Clarification on address format (file offset vs CPU address)

**Related:** Issue #1323

---

## Code Bugs Found

### 1. UpdatePlayerMovementSingle - Missing Elimination Check
**Status:** TODO comment (not implemented)  
**Priority:** MEDIUM  
**Location:** `Source/Routines/UpdatePlayerMovementSingle.s:16`

**Description:**
The function has a TODO comment: "Skip if player is eliminated - TODO: implement elimination check"

**Impact:**
- Eliminated players may still have movement updated
- Wasted CPU cycles processing dead players

**Note:** This is documented as a TODO, not a critical bug.

---

## Bugs Fixed in This Session

The following bugs were fixed during this code review session:

1. **WarmStart optimization (#1329)** - Changed inefficient BS_jsr to same-bank far call
2. **Pause toggle logic** - Fixed inverted logic in HandleConsoleSwitches
3. **CheckEnhancedPause unreachable code** - Fixed early return preventing button checking
4. **Combat.s health check** - Fixed inverted logic (dead attackers continuing processing)
5. **SpriteLoader.s duplicates** - Removed duplicate code and fixed infinite loop
6. **Missile collision temp6 reuse** - Fixed critical variable corruption bug
7. **CacheAOERightHitbox/CacheAOELeftHitbox** - Fixed incomplete implementations
8. **VCS-Consts.s header** - Fixed file header (Grizzards → ChaosFight)

---

## Bugs Requiring Runtime Debugging

All three open GitHub issues (#1323, #1314, #1246) require:
- Runtime debugger traces
- Stack dumps
- Execution context information

These cannot be diagnosed from static code analysis alone and require running the game in a debugger (e.g., Stella debugger) to capture the crash state.

---

## Recommendations

1. **Priority 1:** Debug issues #1323 and #1314 (stack corruption/crash issues)
   - Use Stella debugger to capture full state at crash
   - Trace execution from Reset handler through to crash point
   - Capture stack contents and register state

2. **Priority 2:** Resolve issue #1246 (write to read port)
   - Clarify address format and get full trace
   - Verify if this is related to #1323

3. **Priority 3:** Implement elimination check in UpdatePlayerMovementSingle
   - Currently a TODO, can be implemented when convenient

---

## Notes

- All critical code bugs found in static analysis have been fixed
- Remaining bugs require runtime debugging information
- Codebase appears to be in good shape from a static analysis perspective
- No other obvious bugs found beyond those documented above

