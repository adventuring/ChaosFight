;;; ChaosFight - Source/Routines/TitleScreenRender.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


DrawTitleScreen .proc
          ;; Title Screen Rendering (Publisher/Author/Title screens)
          ;; Returns: Far (return otherbank)
          ;; Render screens using 48×42 bitmaps via titlescreen kernel
          ;; CRITICAL: Sets window values based on gameMode to show correct bitmaps
          ;; Publisher (gameMode 0): AtariAge logo + AtariAge text (bmp_48x2_1, bmp_48x2_2)
          ;; Author (gameMode 1): BRP signature (bmp_48x2_4)
          ;; Title (gameMode 2): ChaosFight title (bmp_48x2_3)
          ;;
          ;; Input: gameMode (global 0-2) = which screen to render
          ;; titleParadeActive (global) = whether to draw parade character
          ;;
          ;; Output: Screen rendered with correct bitmaps, sprites cleared
          ;;
          ;; Mutates: player0x, player0y, player1x, player1y (cleared to 0)
          ;; titlescreenWindow1-4 (set based on gameMode)
          ;;
          ;; Called Routines: DrawParadeCharacter (bank14) - if titleParadeActive set
          ;;
          ;; Constraints: Must be called every frame for modes 0-2
          lda # 0
          sta player0x
          lda # 0
          sta player0y
          lda # 0
          sta player1x
          lda # 0
          sta player1y

          ;; Set window values based on gameMode to show correct bitmaps
          ;; CRITICAL: Window values must be set every frame (titlescreen kernel uses them)
          ;; gameMode 0 = Publisher Prelude, 1 = Author Prelude, 2 = Title Screen
          lda gameMode
          bne CheckAuthorMode

          jmp DrawPublisherScreen

CheckAuthorMode:

          lda gameMode
          cmp # 1
          bne DrawTitleScreenOnly

          jmp DrawAuthorScreen

DrawTitleScreenOnly:
          ;; Default: Title screen (gameMode = 2)
          ;; Fall through to DrawTitleScreenOnly proc (defined below)

.pend

DrawPublisherScreen .proc
          ;; Publisher Prelude: Show AtariAge logo + AtariAge text
          ;; Set titlescreenWindow1 = 42  ; AtariAge logo visible
          ;; Set titlescreenWindow2 = 42  ; AtariAgeText visible
          lda # 42
          sta titlescreenWindow1
          lda # 42
          sta titlescreenWindow2
          ;; Set titlescreenWindow3 = 0  ; ChaosFight hidden
          lda # 0
          sta titlescreenWindow3
          ;; Set titlescreenWindow4 = 0  ; BRP hidden
          lda # 0
          sta titlescreenWindow4
          jmp DrawTitleScreenCommon

.pend

DrawAuthorScreen .proc
          ;; Author Prelude: Show BRP signature only
          ;; Set titlescreenWindow1 = 0   ; AtariAge logo hidden
          ;; Set titlescreenWindow2 = 0  ; AtariAgeText hidden
          lda # 0
          sta titlescreenWindow1
          lda # 0
          sta titlescreenWindow2
          ;; Set titlescreenWindow3 = 0  ; ChaosFight hidden
          lda # 0
          sta titlescreenWindow3
          ;; Set titlescreenWindow4 = 42  ; BRP visible
          lda # 42
          sta titlescreenWindow4
          jmp DrawTitleScreenCommon

.pend

DrawTitleScreenOnly .proc
          ;; Title Screen: Show ChaosFight title only
          ;; Set titlescreenWindow1 = 0   ; AtariAge logo hidden
          ;; Set titlescreenWindow2 = 0  ; AtariAgeText hidden
          lda # 0
          sta titlescreenWindow1
          lda # 0
          sta titlescreenWindow2
          ;; Set titlescreenWindow3 = 42  ; ChaosFight visible
          lda # 42
          sta titlescreenWindow3
          ;; Set titlescreenWindow4 = 0  ; BRP hidden
          lda # 0
          sta titlescreenWindow4
          jmp DrawTitleScreenCommon

.pend

DrawTitleScreenCommon .proc
          ;; Draw character parade if active (Title screen only)
          ;; Cross-bank call to DrawParadeCharacter in bank 13
          ;; Return address: ENCODED with caller bank 8 ($80) for BS_return to decode
          lda # ((>(AfterDrawParadeCharacter-1)) & $0f) | $80  ;;; Encode bank 8 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterDrawParadeCharacter hi (encoded)]
          lda # <(AfterDrawParadeCharacter-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterDrawParadeCharacter hi (encoded)] [SP+0: AfterDrawParadeCharacter lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(DrawParadeCharacter-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterDrawParadeCharacter hi (encoded)] [SP+1: AfterDrawParadeCharacter lo] [SP+0: DrawParadeCharacter hi (raw)]
          lda # <(DrawParadeCharacter-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterDrawParadeCharacter hi (encoded)] [SP+2: AfterDrawParadeCharacter lo] [SP+1: DrawParadeCharacter hi (raw)] [SP+0: DrawParadeCharacter lo]
          ldx # 13
          jmp BS_jsr
AfterDrawParadeCharacter:


          ;; Call titlescreen kernel to render the bitmap(s)
          ;; titledrawscreen is defined in Source/TitleScreen/asm/titlescreen.s
          ;; Kernel uses titlescreenWindow1-4 runtime variables to select bitmaps
            jsr titledrawscreen
          jmp BS_return
          ;;
          ;; Load Title Bitmap
          ;; Loads the ChaosFight title bitmap data for titlescreen
          ;; kernel.
          ;; Generated from Source/Art/ChaosFight.xcf → ChaosFight.png
          ;; SkylineTool creates: Source/Generated/Art.ChaosFight.s
          ;; - BitmapChaosFight: 6 columns × 42 bytes (inverted-y)
          ;; - BitmapChaosFightColors: 84 color values (double-height)

.pend

LoadTitleBitmap .proc
          jmp BS_return
          ;; Configure titlescreen kernel to show Title (ChaosFight)
          ;; Returns: Far (return otherbank)
          ;; bitmap
          ;; Uses 48x2_3 minikernel - set window/height via assembly
          ;; consta

          ;; Other screens’ minikernels should have window=0 in their
          ;; Bitmap data in: Source/Generated/Art.ChaosFight.s
          ;; image files

.pend

