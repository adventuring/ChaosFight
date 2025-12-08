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
          ;; lda temp1 (duplicate)
          cmp RandomArena
          bne skip_4783
          ;; ;; let temp1 = rand & 31
          ;; lda rand (duplicate)
          and # 31
          ;; sta temp1 (duplicate)

          ;; lda rand (duplicate)
          ;; and # 31 (duplicate)
          ;; sta temp1 (duplicate)
skip_4783:


          ;; Get B&W mode state (same logic as GetBWMode)
          ;; Check switchbw and colorBWOverride
          ;; lda switchbw (duplicate)
          ;; sta temp2 (duplicate)
                    ;; if systemFlags & SystemFlagColorBWOverride then let temp2 = 1
          ;; lda systemFlags (duplicate)
          ;; and SystemFlagColorBWOverride (duplicate)
          beq skip_512
          ;; lda # 1 (duplicate)
          ;; sta temp2 (duplicate)
skip_512:

.pend

ReloadArenaColorsDispatch .proc
          ;; Use existing LoadArena color functions (identical behavior)
          ;; Returns: Far (return otherbank)
          ;; Call LoadArenaDispatch to handle color/B&W selection
          ;; (inline logic avoids cross-bank goto issues)
          ;; Cross-bank call to DWS_GetBWMode in bank 15
          ;; lda # >(return_point-1) (duplicate)
          pha
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(DWS_GetBWMode-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(DWS_GetBWMode-1) (duplicate)
          ;; pha (duplicate)
                    ldx # 14
          jmp BS_jsr
return_point:

          ;; lda temp2 (duplicate)
          ;; sta temp6 (duplicate)
          ;; Cross-bank call to LoadArenaByIndex in bank 16
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(LoadArenaByIndex-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(LoadArenaByIndex-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 15 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)

          ;; Load color color table
                    ;; if temp6 then goto RAU_LoadBWColors
          ;; lda temp6 (duplicate)
          ;; beq skip_4158 (duplicate)
          ;; jmp RAU_LoadBWColors (duplicate)
skip_4158:
          ;; Cross-bank call to LoadArenaColorsColor in bank 16
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(LoadArenaColorsColor-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(LoadArenaColorsColor-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 15 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)

          jsr BS_return
.pend

RAU_LoadBWColors .proc
          ;; Load B&W color table
          ;; Returns: Far (return otherbank)
            ;; lda # <ArenaColorsBW (duplicate)
            ;; sta pfcolortable (duplicate)
            ;; lda # >ArenaColorsBW (duplicate)
            ;; sta pfcolortable + 1 (duplicate)
          ;; jsr BS_return (duplicate)



.pend

