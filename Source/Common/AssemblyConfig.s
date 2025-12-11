;;; ChaosFight - Source/Common/AssemblyConfig.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

;;; Configuration for kernel, romsize, and other batariBASIC settings

;; Note: CPU directive is set via command-line (-i flag for 6502 with illegal opcodes)

;;; multisprite is defined in MultiSpriteSuperChip.s
          ;; batariBASIC set commands not needed for 64tass assembly

          ;; Assembly configuration symbols for batariBASIC-generated code
          ;; These are included at the top of the generated assembly file
          ;; Bankswitching configuration
          ;; Note: batariBASIC automatically defines bankswitch from set romsize
          ;; EF bankswitching (64KiB with SuperChip RAM)

          ;; Kernel configuration
          ;; Note: Most of these are automatically defined by batariBASIC based on
          ;; set kernel and set romsize commands, but pfres must be defined manually
          ;; NOTE: .weak protection needed because Preamble.s (which includes this file)
          ;; is included multiple times: once by platform files (NTSC.s/PAL.s/SECAM.s)
          ;; and once by titlescreen.s. 64tass doesn't support .ifndef include guards,
          ;; so .weak/.endweak is the standard way to allow duplicate definitions.
.weak
pfres = 8
.endweak
