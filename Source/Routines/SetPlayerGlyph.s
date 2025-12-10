;;; ChaosFight - Source/Routines/SetPlayerGlyph.bas

;;; Copyright © 2025 Bruce-Robert Pocock.

          ;;
          ;; Unified helper: SetPlayerGlyph

          ;; Sets player sprite pointer to point to 8×16 glyph in ROM SetFontNumbers and sets height.

          ;; Supports both direct glyph index and sprite type lookup modes.

          ;;
          ;; INPUT MODE 1 (direct glyph index):

          ;; temp1 = glyph index (0-15)

          ;; temp3 = player index (0-5)

          ;;
          ;; INPUT MODE 2 (sprite type lookup):

          ;; temp3 = player index (0-5)

          ;; temp4 = sprite type (0=QuestionMark, 1=CPU, 2=No)

          If temp4 is provided, temp1 is looked up from GlyphLookupTable

          ;;
          ;; OUTPUT: playerN pointer and height set (16)

          ;;
          NOTES:

          ;; - Glyphs are packed consecutively in SetFontNumbers (16 bytes per glyph)

          ;; - P0-P5 are all virtual sprites in multisprite kernel - just set pointers to ROM glyphs

          ;; - Must be included in bank 16 to preserve kernel locality

          ;; Glyph lookup table: sprite type (0-2) -> glyph index
GlyphLookupTable:


SetPlayerGlyph .proc


          ;; Unified function supports two input modes:
          ;; Returns: Far (return otherbank)

          ;; Mode 1 (direct): temp1 = glyph index, temp3 = player index

          ;; Mode 2 (lookup): temp3 = player index, temp4 = sprite type (0-2)

          ;; Detect mode: if temp4 is valid sprite type (0-2), use lookup mode

          ;; Otherwise assume temp1 already contains glyph index

          ;; temp4 is 0-2, so this is sprite type lookup mode
          lda temp4
          cmp # 3
          bcc skip_1166
skip_1166:


          ;; Look up glyph index from table (overwrites temp1)
                    let temp1 = GlyphLookupTable[temp4]         
          lda temp4
          asl
          tax
          lda GlyphLookupTable,x
          sta temp1

.pend

SetPlayerGlyphDirectMode .proc

          ;; Calculate offset into SetFontNumbers (16 bytes per glyph)
          ;; Returns: Far (return otherbank)
                    let temp2 = temp1 * 16

          ;; Set player pointer and height based on player index

          ;; Calculate base address: SetFontNumbers + temp2 (shared calculation)
          lda # <SetFontNumbers

            clc

            adc temp2

            sta temp4

            lda # >SetFontNumbers

            adc # 0

            sta temp5


          ;; Store to appropriate player pointer based on temp3 (using on...goto for efficiency)

          ;; Fall through to P5 if temp3 > 4
          jmp SetPlayerGlyphP0

.pend

SetPlayerGlyphP5 .proc
          ;; Returns: Far (return otherbank)

            lda temp4

            sta player5pointerlo

            lda temp5

            sta player5pointerhi

            lda # 16

            sta player5height

          jsr BS_return

.pend

SetPlayerGlyphP0 .proc
          ;; Returns: Far (return otherbank)

            lda temp4

            sta player0pointerlo

            lda temp5

            sta player0pointerhi

            lda # 16

            sta player0height

          jsr BS_return

.pend

SetPlayerGlyphP1 .proc
          ;; Returns: Far (return otherbank)

            lda temp4

            sta player1pointerlo

            lda temp5

            sta player1pointerhi

            lda # 16

            sta player1height

          jsr BS_return

.pend

SetPlayerGlyphP2 .proc
          ;; Returns: Far (return otherbank)

            lda temp4

            sta player2pointerlo

            lda temp5

            sta player2pointerhi

            lda # 16

            sta player2height

          jsr BS_return

.pend

SetPlayerGlyphP3 .proc
          ;; Returns: Far (return otherbank)

            lda temp4

            sta player3pointerlo

            lda temp5

            sta player3pointerhi

            lda # 16

            sta player3height

          jsr BS_return

.pend

SetPlayerGlyphP4 .proc
          ;; Returns: Far (return otherbank)

            lda temp4

            sta player4pointerlo

            lda temp5

            sta player4pointerhi

            lda # 16

            sta player4height

          jsr BS_return

          ;; Backward compatibility wrappers
          ;; Returns: Far (return otherbank)

.pend

SetGlyph .proc


          ;; Wrapper for SetPlayerGlyph - direct glyph index mode
          ;; Returns: Far (return otherbank)

          ;; Input: temp1 = glyph index, temp3 = player index

          ;; Set temp4 to invalid value to force direct mode
          lda # 255
          sta temp4
          jmp SetPlayerGlyph

.pend

CopyGlyphToPlayer .proc


          ;; Wrapper for SetPlayerGlyph - sprite type lookup mode
          ;; Returns: Far (return otherbank)

          ;; Input: temp3 = player index, temp4 = sprite type (0-2)

          ;; temp4 already set by caller, will trigger lookup mode
          jmp SetPlayerGlyph

.pend

