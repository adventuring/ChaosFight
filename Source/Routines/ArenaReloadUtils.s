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

          ;; Set temp1 = rand & 31
          lda rand
          and # 31
          sta temp1

SkipRandomSelection:

          ;; Get B&W mode state (same logic as GetBWMode)
          ;; Check switchbw and colorBWOverride
          lda switchbw
          sta temp2
          ;; If systemFlags & SystemFlagColorBWOverride, then set temp2 = 1
          lda systemFlags
          and # SystemFlagColorBWOverride
          beq CheckBWModeDone
          lda # 1
          sta temp2
CheckBWModeDone:
          beq SkipBWOverride

          lda # 1
          sta temp2

SkipBWOverride:

.pend

ReloadArenaColorsDispatch .proc
          ;; Use existing LoadArena color functions (identical behavior)
          ;; Returns: Far (return otherbank)
          ;; Call LoadArenaDispatch to handle color/B&W selection
          ;; (inline logic avoids cross-bank jmp issues)
          ;; Cross-bank call to DWS_GetBWMode in bank 15
          lda # >(AfterGetBWModeWinScreen-1)
          pha
          lda # <(AfterGetBWModeWinScreen-1)
          pha
          lda # >(GetBWModeWinScreen-1)
          pha
          lda # <(GetBWModeWinScreen-1)
          pha
          ldx # 14
          jmp BS_jsr

AfterGetBWModeWinScreen:

          lda temp2
          sta temp6
          ;; Cross-bank call to LoadArenaByIndex in bank 16
          lda # >(AfterLoadArenaByIndexReload-1)
          pha
          lda # <(AfterLoadArenaByIndexReload-1)
          pha
          lda # >(LoadArenaByIndex-1)
          pha
          lda # <(LoadArenaByIndex-1)
          pha
          ldx # 15
          jmp BS_jsr

AfterLoadArenaByIndexReload:

          ;; Load color color table
          ;; if temp6 then jmp RAU_LoadBWColors
          lda temp6
          beq LoadColorColors
          jmp LoadBWColorsArenaReload
LoadColorColors:
          ;; Cross-bank call to LoadArenaColorsColor in bank 16
          lda # >(AfterLoadArenaColorsColor-1)
          pha
          lda # <(AfterLoadArenaColorsColor-1)
          pha
          lda # >(LoadArenaColorsColor-1)
          pha
          lda # <(LoadArenaColorsColor-1)
          pha
                    ldx # 15
          jmp BS_jsr
AfterLoadArenaColorsColor:

          jmp BS_return
.pend

LoadBWColorsArenaReload .proc
          ;; Load B&W color table
          ;; Returns: Far (return otherbank)
            lda # <ArenaColorsBW
            sta pfcolortable
            lda # >ArenaColorsBW
            sta pfcolortable + 1
          jmp BS_return



.pend

