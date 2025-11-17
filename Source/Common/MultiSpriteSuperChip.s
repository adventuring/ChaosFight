; ChaosFight superchip RAM definitions and ChaosFight-specific additions.
; The upstream multisprite definitions are included separately.
; Licensed under CC0 to match upstream batariBASIC headers.

 include "2600basic_variable_redefs.h"

; Essential constants needed for batariBASIC

gamenumber        EQU $00    ; Game number for gameselect minikernel

miniscoretable   EQU $0000  ; Score minikernel table

; Kernel configuration constants
pfscore          EQU 1    ; Enable playfield score feature
noscore          EQU 0    ; Enable score display (health bars)
