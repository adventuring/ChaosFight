;;; ChaosFight - Source/Routines/ArenaReloadUtils.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


ReloadArenaColors .proc
          ;; Reload arena colors based on current Color/B&W switch
          ;; Returns: Far (return otherbank)
          ;; sta

          ;; Uses same logic as LoadArenaColors (consolidated to avoid duplication)

          ;; Get current arena index
          lda selectedArena_R
          sta temp1
          ;; Handle random arena (use stored random selection)
          lda temp1
          cmp # RandomArena
          bne SkipRandomSelection

          ;; let temp1 = rand & 31
          lda rand
          and # 31
          sta temp1

SkipRandomSelection:

          ;; Get B&W mode state (same logic as GetBWMode)
          ;; Check switchbw and colorBWOverride
          lda switchbw
          sta temp2
          if systemFlags & SystemFlagColorBWOverride then let temp2 = 1
          lda systemFlags
          and # SystemFlagColorBWOverride
          beq SkipBWOverride

          lda # 1
          sta temp2

SkipBWOverride:

.pend

ReloadArenaColorsDispatch .proc
          ;; Use existing LoadArena color functions (identical behavior)
          ;; Returns: Far (return otherbank)
          ;; Call LoadArenaDispatch to handle color/B&W selection
          ;; (inline logic avoids cross-bank goto issues)
          ;; Cross-bank call to DWS_GetBWMode in bank 15
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(DWS_GetBWMode-1)
          pha
          lda # <(DWS_GetBWMode-1)
          pha
          ldx # 14
          jmp BS_jsr

return_point:

          lda temp2
          sta temp6
          ;; Cross-bank call to LoadArenaByIndex in bank 16
          lda # >(return_point2-1)
          pha
          lda # <(return_point2-1)
          pha
          lda # >(LoadArenaByIndex-1)
          pha
          lda # <(LoadArenaByIndex-1)
          pha
          ldx # 15
          jmp BS_jsr

return_point2:

          ;; Load color color table
          ;; if temp6 then goto RAU_LoadBWColors
          lda temp6
          beq LoadColorColors
          jmp RAU_LoadBWColors
LoadColorColors:
          ;; Cross-bank call to LoadArenaColorsColor in bank 16
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(LoadArenaColorsColor-1)
          pha
          lda # <(LoadArenaColorsColor-1)
          pha
                    ldx # 15
          jmp BS_jsr
return_point:

          jsr BS_return
.pend

RAU_LoadBWColors .proc
          ;; Load B&W color table
          ;; Returns: Far (return otherbank)
            lda # <ArenaColorsBW
            sta pfcolortable
            lda # >ArenaColorsBW
            sta pfcolortable + 1
          jsr BS_return



.pend

