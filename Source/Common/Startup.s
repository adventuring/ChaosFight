;;;; ChaosFight - Source/Common/Startup.s
;;;; Copyright © 2025 Bruce-Robert Pocock.
;;;; Derived from Tools/batariBASIC/includes/startup.asm (CC0)
;;;;
;;;; DEPRECATED: This file is no longer used. Cold start is now in Reset handler,
;;;; and warm start (memory clearing) is now in WarmStart (ConsoleHandling.s).
;;;; This file is kept for reference only.

start = ColdStart          ;;; Alias for bankswitch return mechanism (deprecated)

StartupInit .block
          ;; DEPRECATED: This code is no longer used
          ;; Cold start procedure is now in Reset handler (BankSwitching.s)
          ;; Warm start memory clearing is now in WarmStart (ConsoleHandling.s)
          ;; This block is kept for reference only
.bend
