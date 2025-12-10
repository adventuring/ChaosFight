
SetPublisherWindowValues .proc
          ;;
          ;; Returns: Near (return thisbank) - called same-bank from BeginPublisherPrelude
          ;; ChaosFight - Source/Routines/TitlescreenWindowControl.bas
          ;; Copyright © 2025 Bruce-Robert Pocock.
          ;; Titlescreen Window Control
          ;;
          ;; Screen-specific window value initialization for
          ;; titlescreen kernel.
          ;; Window values control which bitmaps display on each
          ;; screen.
          Requirements:
          ;;
          ;; Publisher (gameMode 0): AtariAge logo + AtariAge text (2
          ;; bitmaps)
          ;; Author (gameMode 1): Interworldly only (1 bitmap) - needs
          ;; different slot
          ;; Title (gameMode 2): ChaosFight only (1 bitmap)
          ;; NOTE: Window values are compile-time constants in the
          ;; titlescreen kernel.
          ;; These routines set window values via assembly if the
          ;; kernel supports
          ;; runtime modification. Otherwise, window values must be set
          ;; at compile time.
          ;; Initialize window values for Publisher screen
          ;; Shows: AtariAge logo (bmp_48x2_1) + AtariAge text
          ;; (bmp_48x2_2)
          ;; Hides: ChaosFight (bmp_48x2_3), BRP (bmp_48x2_4)
          ;; Set runtime window values for Publisher screen (2 bitmaps
          ;; visible)
          ;;
          ;; Input: None
          ;;
          ;; Output: titlescreenWindow1-4 set for Publisher screen
          ;;
          ;; Mutates: titlescreenWindow1, titlescreenWindow2,
          ;; titlescreenWindow3, titlescreenWindow4
          ;;
          ;; Called Routines: None
          ;; Constraints: None
          ;; let titlescreenWindow1 = 42  ; AtariAge logo visible
          lda # 42
          sta titlescreenWindow1
          ;; let titlescreenWindow2 = 42  ; AtariAgeText visible
          lda # 42
          sta titlescreenWindow2
          ;; let titlescreenWindow3 = 0  ; ChaosFight hidden
          lda # 0
          sta titlescreenWindow3
          ;; let titlescreenWindow4 = 0  ; BRP hidden
          lda # 0
          sta titlescreenWindow4
          rts

.pend

SetAuthorWindowValues .proc

          ;; Initialize window values for Author screen
          ;; Returns: Near (return thisbank) - called same-bank from BeginAuthorPrelude
          ;; Shows: BRP (slot 4)
          ;; Hides: AtariAge logo (bmp_48x2_1), AtariAgeText
          ;; (bmp_48x2_2), ChaosFight (bmp_48x2_3)
          ;; Set runtime window values for Author screen (BRP
          ;; visible in slot 4)
          ;;
          ;; Input: None
          ;;
          ;; Output: titlescreenWindow1-4 set for Author screen
          ;;
          ;; Mutates: titlescreenWindow1, titlescreenWindow2,
          ;; titlescreenWindow3, titlescreenWindow4
          ;;
          ;; Called Routines: None
          ;; Constraints: None
          ;; let titlescreenWindow1 = 0  ; AtariAge logo hidden
          lda # 0
          sta titlescreenWindow1
          ;; let titlescreenWindow2 = 0  ; AtariAgeText hidden
          lda # 0
          sta titlescreenWindow2
          ;; let titlescreenWindow3 = 0  ; ChaosFight hidden
          lda # 0
          sta titlescreenWindow3
          ;; let titlescreenWindow4 = 42  ; BRP visible
          lda # 42
          sta titlescreenWindow4
          rts

.pend

SetTitleWindowValues .proc
          ;; Initialize window values for Title screen
          ;; Returns: Near (return thisbank) - called same-bank from BeginTitleScreen
          ;; Shows: ChaosFight (bmp_48x2_3) only
          ;; Hides: AtariAge logo (bmp_48x2_1), AtariAgeText
          ;; (bmp_48x2_2), BRP (bmp_48x2_4)
          ;; Set runtime window values for Title screen (1 bitmap
          ;; visible)
          ;;
          ;; Input: None
          ;;
          ;; Output: titlescreenWindow1-4 set for Title screen
          ;;
          ;; Mutates: titlescreenWindow1, titlescreenWindow2,
          ;; titlescreenWindow3, titlescreenWindow4
          ;;
          ;; Called Routines: None
          ;; Constraints: None
          ;; let titlescreenWindow1 = 0  ; AtariAge logo hidden
          lda # 0
          sta titlescreenWindow1
          ;; let titlescreenWindow2 = 0  ; AtariAgeText hidden
          lda # 0
          sta titlescreenWindow2
          ;; let titlescreenWindow3 = 42  ; ChaosFight visible
          lda # 42
          sta titlescreenWindow3
          ;; let titlescreenWindow4 = 0  ; Interworldly hidden
          lda # 0
          sta titlescreenWindow4
          rts


.pend

