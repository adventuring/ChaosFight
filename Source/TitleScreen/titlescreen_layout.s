;;;; ChaosFight - Source/TitleScreen/titlescreen_layout.s
;;;; Copyright © 2025 Bruce-Robert Pocock.

;;;; To use a minikernel, just list it below. They’ll be drawn on the screen
;;;; in the order they were listed.
;;;;
;;;; If a minikernel isn’t listed, it won’t be compiled into the program, and
;;;; it won’t use any ROM space.

titlescreenlayout .macro
	;; For 48×42 bitmaps using ×2 drawing style (double-height mode)
	;; Each bitmap row is displayed as 2 scanlines: 42 rows → 84 scanlines on screen
	;; Three admin screens use four minikernel slots:
	;;   - 48x2_1: AtariAge logo bitmap
	;;   - 48x2_2: AtariAge text bitmap
	;;   - 48x2_3: ChaosFight title bitmap
	;;   - 48x2_4: BRP signature bitmap (Author screen)
	;; Publisher screen: Shows 48x2_1 (logo) + 48x2_2 (text) - both window=42
	;; Author screen: Shows only 48x2_4 (BRP) - window=42
	;; Title screen: Shows only 48x2_3 (ChaosFight) - window=42
	;; Each screen activates only its minikernel by setting height/window = 0 for others
draw_48x2_1:

draw_48x2_2:

draw_48x2_3:

draw_48x2_4:

.endm

;; Minikernel choices are:
;
;; draw_48x1_1, draw_48x1_2, draw_48x1_3
;; 	The first, second, and third 48-wide single-line bitmap minikernels
;
;; draw_48x2_1, draw_48x2_2, draw_48x2_3
;; 	The first, second, and third 48-wide double-line bitmap minikernels
;
;; draw_96x2_1, draw_96x2_2, draw_96x2_3
;; 	The first, second, and third 96-wide double-line bitmap minikernels
;
;; draw_gameselect
;; 	The game selection display minikernel
;
;; draw_score
;;	A minikernel that draws the score
;
;; draw_space 10
;;	A minikernel used to add blank space between other minikernels





