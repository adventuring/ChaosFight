;;; ChaosFight - Source/Banks/Banks.s
;;; Copyright © 2025 Bruce-Robert Pocock.

;; CRITICAL: Include Preamble.s FIRST - it must be included only once
;; This provides all symbol definitions (TIA registers, variables, constants, etc.)
;; that are needed by all banks
.include "Source/Common/Preamble.s"

;;; Bank 0: Sounds & Music 1

.include "Bank0.s"

;;; Define global bank switching labels referencing Bank 0 versions
;;; All banks have the same code at the same CPU addresses, so we reference Bank 0
BS_jsr = Bank0BS.BS_jsr
BS_return = Bank0BS.BS_return

          ;; Bank 1: Character Art 1

.include "Bank1.s"

          ;; Bank 2: Character Art 2

.include "Bank2.s"

          ;; Bank 3: Character Art 3

.include "Bank3.s"

          ;; Bank 4: Character Art 4

.include "Bank4.s"

          ;; Bank 5: Character select and combat

.include "Bank5.s"

          ;; Bank 6: Missile handling and collisions

.include "Bank6.s"

          ;; Bank 7: Physics, rendering, health systems

.include "Bank7.s"

          ;; Bank 8: Title screens and preludes

.include "Bank8.s"

          ;; Bank 9: Character select and sprite loading

.include "Bank9.s"

          ;; Bank 10: Core game loop and attacks

.include "Bank10.s"

          ;; Bank 11: Transitions for falling, arena, winner

.include "Bank11.s"

          ;; Bank 12: Startup, input, movement systems

.include "Bank12.s"

          ;; Bank 13: Console handling and art routing

.include "Bank13.s"

          ;; Bank 14: Sounds & Music 2

.include "Bank14.s"

          ;; Bank 15: Main loop, drawscreen, ROM graphics (playfields)

.include "Bank15.s"
