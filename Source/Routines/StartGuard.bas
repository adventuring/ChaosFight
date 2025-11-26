          rem ChaosFight - Source/Routines/StartGuard.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

StartGuard
          asm
StartGuard
end
          rem
          rem Start Guard
          rem Activate guard state for the specified player.
          rem Input: temp1 = player index (0-3)
          rem        GuardTimerMaxFrames (constant) = guard duration in
          rem        frames
          rem
          rem Output: playerState[] guard bit set, playerTimers_W[] set
          rem to guard duration
          rem
          rem Mutates: playerState[] (guard bit set), playerTimers_W[]
          rem (set to GuardTimerMaxFrames)
          rem
          rem Called Routines: None
          rem Constraints: None
          rem Set guard bit in playerState
          let playerState[temp1] = playerState[temp1] | 2

          rem Set guard duration timer using GuardTimerMaxFrames (TV-standard aware)
          rem Store guard duration timer in playerTimers array
          rem This timer will be decremented each frame until it reaches 0
          let playerTimers_W[temp1] = GuardTimerMaxFrames

          return thisbank
