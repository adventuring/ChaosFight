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
          ;; Cross-bank call to DWS_GetBWMode in bank 14
          ;; Return address: ENCODED with caller bank 13 ($d0) for BS_return to decode
          lda # ((>(AfterGetBWModeWinScreen-1)) & $0f) | $d0  ;;; Encode bank 13 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterGetBWModeWinScreen hi (encoded)]
          lda # <(AfterGetBWModeWinScreen-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterGetBWModeWinScreen hi (encoded)] [SP+0: AfterGetBWModeWinScreen lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(GetBWModeWinScreen-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterGetBWModeWinScreen hi (encoded)] [SP+1: AfterGetBWModeWinScreen lo] [SP+0: GetBWModeWinScreen hi (raw)]
          lda # <(GetBWModeWinScreen-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterGetBWModeWinScreen hi (encoded)] [SP+2: AfterGetBWModeWinScreen lo] [SP+1: GetBWModeWinScreen hi (raw)] [SP+0: GetBWModeWinScreen lo]
          ldx # 14
          jmp BS_jsr

AfterGetBWModeWinScreen:

          lda temp2
          sta temp6
          ;; Cross-bank call to LoadArenaByIndex in bank 16
          ;; Return address: ENCODED with caller bank 13 ($d0) for BS_return to decode
          lda # ((>(AfterLoadArenaByIndexReload-1)) & $0f) | $d0  ;;; Encode bank 13 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterLoadArenaByIndexReload hi (encoded)]
          lda # <(AfterLoadArenaByIndexReload-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterLoadArenaByIndexReload hi (encoded)] [SP+0: AfterLoadArenaByIndexReload lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(LoadArenaByIndex-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterLoadArenaByIndexReload hi (encoded)] [SP+1: AfterLoadArenaByIndexReload lo] [SP+0: LoadArenaByIndex hi (raw)]
          lda # <(LoadArenaByIndex-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterLoadArenaByIndexReload hi (encoded)] [SP+2: AfterLoadArenaByIndexReload lo] [SP+1: LoadArenaByIndex hi (raw)] [SP+0: LoadArenaByIndex lo]
          ldx # 15
          jmp BS_jsr

AfterLoadArenaByIndexReload:

          ;; Load color color table
          ;; if temp6 then jmp RAU_LoadBWColors
          lda temp6
          beq LoadColorColors
          jmp LoadBWColorsArenaReload
LoadColorColors:
          ;; Cross-bank call to LoadArenaColorsColor in bank 15
          ;; Return address: ENCODED with caller bank 13 ($d0) for BS_return to decode
          lda # ((>(AfterLoadArenaColorsColor-1)) & $0f) | $d0  ;;; Encode bank 13 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterLoadArenaColorsColor hi (encoded)]
          lda # <(AfterLoadArenaColorsColor-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterLoadArenaColorsColor hi (encoded)] [SP+0: AfterLoadArenaColorsColor lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(LoadArenaColorsColor-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterLoadArenaColorsColor hi (encoded)] [SP+1: AfterLoadArenaColorsColor lo] [SP+0: LoadArenaColorsColor hi (raw)]
          lda # <(LoadArenaColorsColor-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterLoadArenaColorsColor hi (encoded)] [SP+2: AfterLoadArenaColorsColor lo] [SP+1: LoadArenaColorsColor hi (raw)] [SP+0: LoadArenaColorsColor lo]
          ldx # 15
          jmp BS_jsr
AfterLoadArenaColorsColor:

          jmp BS_return
.pend

LoadBWColorsArenaReload .proc
          ;; Load B&W color table
          ;; Returns: Far (return otherbank)
            lda # <ArenaColorsBW
            sta pfColorTable
            lda # >ArenaColorsBW
            sta pfColorTable + 1
          jmp BS_return



.pend

