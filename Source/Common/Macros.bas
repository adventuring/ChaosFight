rem ===========================================================================
rem ChaosFight - Common Macros
rem ===========================================================================
rem This file contains useful macros for game development
rem ===========================================================================

rem Bank switching macro (F4 style for future expansion)
macro bankswitch
asm
lda #{1}
sta $FFF4
end
end

rem Safe division macro (avoid division by zero)
macro safe_divide dividend divisor result
if {divisor} = 0 then {result} = 0 else {result} = {dividend} / {divisor}
end

rem Clamp value between min and max
macro clamp value min max
if {value} < {min} then {value} = {min}
if {value} > {max} then {value} = {max}
end

rem Random number generator (simple LFSR)
macro random_byte
asm
lda rand_seed
lsr
bcc .skip
eor #$B4
.skip
sta rand_seed
end
end

rem Collision detection macro (simplified)
macro check_collision x1 y1 w1 h1 x2 y2 w2 h2
temp1 = 0
if {x1} < {x2} + {w2} && {x1} + {w1} > {x2} && {y1} < {y2} + {h2} && {y1} + {h1} > {y2} then temp1 = 1
end

rem Play sound effect macro
macro play_sfx sound_index
AUDV0 = 8
AUDC0 = 4
AUDF0 = {sound_index}
end

rem Wait for vertical sync
macro vsync
asm
lda #2
sta VSYNC
sta VBLANK
lda #45
sta TIM64T
end
end

rem End of macros
