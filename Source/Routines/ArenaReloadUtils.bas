          rem ChaosFight - Source/Routines/ArenaReloadUtils.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

ReloadArenaColors
          rem Returns: Far (return otherbank)
          asm
ReloadArenaColors
end
          rem Reload arena colors based on current Color/B&W switch
          rem Returns: Far (return otherbank)
          rem state
          rem Uses same logic as LoadArenaColors (consolidated to avoid duplication)

          rem Get current arena index
          let temp1 = selectedArena_R
          rem Handle random arena (use stored random selection)
          if temp1 = RandomArena then temp1 = rand & 31

          rem Get B&W mode state (same logic as GetBWMode)
          rem Check switchbw and colorBWOverride
          let temp2 = switchbw
          if systemFlags & SystemFlagColorBWOverride then temp2 = 1

ReloadArenaColorsDispatch
          rem Returns: Far (return otherbank)
          asm
ReloadArenaColorsDispatch
end
          rem Use existing LoadArena color functions (identical behavior)
          rem Returns: Far (return otherbank)
          rem Call LoadArenaDispatch to handle color/B&W selection
          rem (inline logic avoids cross-bank goto issues)
          gosub DWS_GetBWMode bank15
          let temp6 = temp2
          gosub LoadArenaByIndex bank16
          rem Load color color table
          if temp6 then goto RAU_LoadBWColors
          gosub LoadArenaColorsColor bank16
          return otherbank
RAU_LoadBWColors
          rem Load B&W color table
          rem Returns: Far (return otherbank)
          asm
            lda #<ArenaColorsBW
            sta pfcolortable
            lda #>ArenaColorsBW
            sta pfcolortable + 1
end
          return otherbank


