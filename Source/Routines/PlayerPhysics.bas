          rem ChaosFight - Source/Routines/PlayerPhysics.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem Wrapper include: compile the gravity/momentum routines exactly once.
          rem The bank8 build owns these labels; duplicating them tripped Issue #875
          rem when DASM decided .MomentumRecoveryNext should live past $10000.

#include "Source/Routines/PlayerPhysicsGravity.bas"
