; ChaosFight - Source/Common/AssemblyConfig.s
; Copyright © 2025 Interworldly Adventuring, LLC.
; Assembly configuration symbols for batariBASIC-generated code
; These are included at the top of the generated assembly file

; Kernel configuration
multisprite = 1
playercolors = 1
player1colors = 1
pfcolors = 1

; Bank switching configuration
; TV-standard-specific bankswitch values are set conditionally below
superchip = 1
bankswitch_hotspot = $1FE0

; Bank switching value per TV standard
; NTSC uses 64K bankswitching (64), PAL/SECAM use 32K (32)
; Only set if not already defined by batariBASIC or other includes
        IFNCONST bankswitch
        IFCONST TV_NTSC
bankswitch = 64
        ELSE
bankswitch = 32
        ENDIF
        ENDIF

; Code generation options
noscore = 0
qtcontroller = 0
pfres = 12
bscode_length = 32
