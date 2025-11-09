          rem ChaosFight - Source/Routines/ArenaReloadUtils.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Arena color reloading utilities moved for bank optimization

ReloadArenaColors
          rem Reload arena colors based on current Color/B&W switch
          rem state
          rem Uses same logic as LoadArenaColors (consolidated to avoid duplication)
          
          let temp1 = selectedArena_R
          rem Get current arena index
          rem Handle random arena (use stored random selection)
          if temp1 = RandomArena then let temp1 = rand & 31
          
          rem Get B&W mode state (same logic as GetBWMode)
          let temp2 = switchbw
          rem Check switchbw and colorBWOverride
          if systemFlags & SystemFlagColorBWOverride then let temp2 = 1
          
ReloadArenaColorsDispatch
          rem Use existing LoadArena color functions (identical behavior)
          if temp2 then goto LoadArenaColorsBW bank16
          goto LoadArenaColorsColor bank16

