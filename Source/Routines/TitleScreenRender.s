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
          ;; lda # 0 (duplicate)
          ;; sta player0y (duplicate)
          ;; lda # 0 (duplicate)
          ;; sta player1x (duplicate)
          ;; lda # 0 (duplicate)
          ;; sta player1y (duplicate)

          ;; Set window values based on gameMode to show correct bitmaps
          ;; CRITICAL: Window values must be set every frame (titlescreen kernel uses them)
          ;; gameMode 0 = Publisher Prelude, 1 = Author Prelude, 2 = Title Screen
          ;; lda gameMode (duplicate)
          cmp # 0
          bne skip_4934
          jmp DrawPublisherScreen
skip_4934:


          ;; lda gameMode (duplicate)
          ;; cmp # 1 (duplicate)
          ;; bne skip_8757 (duplicate)
          ;; jmp DrawAuthorScreen (duplicate)
skip_8757:


          ;; Default: Title screen (gameMode = 2)
          ;; jmp DrawTitleScreenOnly (duplicate)

.pend

DrawPublisherScreen .proc
          ;; Publisher Prelude: Show AtariAge logo + AtariAge text
                    ;; let titlescreenWindow1 = 42  ; AtariAge logo visible
                    ;; let titlescreenWindow2 = 42  ; AtariAgeText visible
          ;; lda # 42 (duplicate)
          ;; sta titlescreenWindow2 (duplicate)
                    ;; let titlescreenWindow3 = 0  ; ChaosFight hidden
          ;; lda # 0 (duplicate)
          ;; sta titlescreenWindow3 (duplicate)
                    ;; let titlescreenWindow4 = 0  ; BRP hidden
          ;; lda # 0 (duplicate)
          ;; sta titlescreenWindow4 (duplicate)
          ;; jmp DrawTitleScreenCommon (duplicate)

.pend

DrawAuthorScreen .proc
          ;; Author Prelude: Show BRP signature only
                    ;; let titlescreenWindow1 = 0   ; AtariAge logo hidden
                    ;; let titlescreenWindow2 = 0  ; AtariAgeText hidden
          ;; lda # 0 (duplicate)
          ;; sta titlescreenWindow2 (duplicate)
                    ;; let titlescreenWindow3 = 0  ; ChaosFight hidden
          ;; lda # 0 (duplicate)
          ;; sta titlescreenWindow3 (duplicate)
                    ;; let titlescreenWindow4 = 42  ; BRP visible
          ;; lda # 42 (duplicate)
          ;; sta titlescreenWindow4 (duplicate)
          ;; jmp DrawTitleScreenCommon (duplicate)

DrawTitleScreenOnly
          ;; Title Screen: Show ChaosFight title only
                    ;; let titlescreenWindow1 = 0   ; AtariAge logo hidden
                    ;; let titlescreenWindow2 = 0  ; AtariAgeText hidden
          ;; lda # 0 (duplicate)
          ;; sta titlescreenWindow2 (duplicate)
                    ;; let titlescreenWindow3 = 42  ; ChaosFight visible
          ;; lda # 42 (duplicate)
          ;; sta titlescreenWindow3 (duplicate)
                    ;; let titlescreenWindow4 = 0  ; BRP hidden
          ;; lda # 0 (duplicate)
          ;; sta titlescreenWindow4 (duplicate)

DrawTitleScreenCommon
;; DrawTitleScreenCommon (duplicate)
          ;; Draw character parade if active (Title screen only)
          ;; Cross-bank call to DrawParadeCharacter in bank 14
          ;; lda # >(return_point-1) (duplicate)
          pha
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(DrawParadeCharacter-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(DrawParadeCharacter-1) (duplicate)
          ;; pha (duplicate)
                    ldx # 13
          ;; jmp BS_jsr (duplicate)
return_point:


          ;; Call titlescreen kernel to render the bitmap(s)
          ;; titledrawscreen is defined in Source/TitleScreen/asm/titlescreen.s
          ;; Kernel uses titlescreenWindow1-4 runtime variables to select bitmaps
            jsr titledrawscreen
          ;; jsr BS_return (duplicate)
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
          ;; jsr BS_return (duplicate)
          ;; Configure titlescreen kernel to show Title (ChaosFight)
          ;; Returns: Far (return otherbank)
          ;; bitmap
          ;; Uses 48x2_3 minikernel - set window/height via assembly
          ;; consta

          ;; Other screens’ minikernels should have window=0 in their
          ;; Bitmap data in: Source/Generated/Art.ChaosFight.s
          ;; image files

.pend

