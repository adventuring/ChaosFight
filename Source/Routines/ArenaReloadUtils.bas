          rem ChaosFight - Source/Routines/ArenaReloadUtils.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Arena color reloading utilities moved for bank optimization

ReloadArenaColors
          asm
ReloadArenaColors
end
          rem Reload arena colors based on current Color/B&W switch
          rem state
          rem Uses same logic as LoadArenaColors (consolidated to avoid duplication)

          let temp1 = selectedArena_R
          rem Get current arena index
          rem Handle random arena (use stored random selection)
          if temp1 = RandomArena then temp1 = rand & 31

          rem Get B&W mode state (same logic as GetBWMode)
          let temp2 = switchbw
          rem Check switchbw and colorBWOverride
          if systemFlags & SystemFlagColorBWOverride then temp2 = 1

ReloadArenaColorsDispatch
          asm
ReloadArenaColorsDispatch
end
          rem Use existing LoadArena color functions (identical behavior)
          rem Call LoadArenaDispatch to handle color/B&W selection
          rem (inline logic avoids cross-bank goto issues)
          gosub DWS_GetBWMode bank15
          let temp6 = temp2
          gosub LoadArenaByIndex bank16
          if temp6 then goto RAU_LoadBWColors
          rem Load color color table
          gosub LoadArenaColorsColor bank16
          return
RAU_LoadBWColors
            rem Load B&W color table
            asm
              lda #<ArenaColorsBW
              sta pfcolortable
              lda #>ArenaColorsBW
              sta pfcolortable+1
            end
          return


