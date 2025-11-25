          rem ChaosFight - Source/Routines/ApplyGuardColor.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

ApplyGuardColor
          rem Apply guard color effect (light cyan for NTSC/PAL, cyan for SECAM)
          rem while a player is actively guarding.
          rem
          rem Input: temp1 = player index (0-3)
          rem        playerState[] (global) = player state flags (bit 1 = guarding)
          rem
          rem Output: Player color forced to ColCyan(12) while guarding
          rem Mutates: temp1-temp2, COLUP0, _COLUP1, COLUP2, COLUP3
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must remain colocated with GuardColor0-GuardColor3 jump table
          rem Check if player is guarding
          let temp2 = playerState[temp1] & 2
          rem Not guarding
          if !temp2 then return

          rem set light cyan color
          rem Optimized: Apply guard color with computed assignment
          on temp1 goto GuardColor0 GuardColor1 GuardColor2 GuardColor3
GuardColor0
          COLUP0 = ColCyan(12)
          return
GuardColor1
          _COLUP1 = ColCyan(12)
          return
GuardColor2
          COLUP2 = ColCyan(12)
          return
GuardColor3
          COLUP3 = ColCyan(12)
          return

