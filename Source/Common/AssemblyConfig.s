;;; ChaosFight - Source/Common/AssemblyConfig.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

;;; Configuration for kernel, romsize, and other batariBASIC settings

;; Note: CPU directive is set via command-line (-i flag for 6502 with illegal opcodes)

;;; multisprite is defined in MultiSpriteSuperChip.s
          ;; batariBASIC set commands removed - not needed for 64tass assembly

          ;; Assembly configuration symbols for batariBASIC-generated code
          ;; These are included at the top of the generated assembly file
          ;; Bankswitching configuration
          ;; Note: batariBASIC automatically defines bankswitch from set romsize
          ;; EF bankswitching (64KiB with SuperChip RAM)

          ;; Kernel configuration
          ;; Note: Most of these are automatically defined by batariBASIC based on
pfres = 8
          ;; set kernel and set romsize commands, but pfres must be defined manually
          ;; Playfield resolution: 8 rows (fixed for all playfields)

;;; Forward declarations removed - symbols will be defined when their respective files are included
