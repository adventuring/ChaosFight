          rem ChaosFight - Source/Common/Preamble.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          set includesfile ChaosFight.inc

;; CRITICAL: Include AssemblyConfig.bas FIRST to set processor directive
;; This must be before MultiSpriteSuperChip.s (which includes vcs.h and macro.h)
#include "Source/Common/AssemblyConfig.bas"

          asm

;; Include sleep macro
#include "Source/Routines/Sleep.s"

;; CRITICAL: Include MultiSpriteSuperChip.s FIRST to define all symbols before
;; batariBASIC includes are processed. This ensures symbols like frame,
;; missile0height, missile1height, qtcontroller, playfieldRow, miniscoretable,
;; etc. are available when batariBASIC includes reference them.
#include "Source/Common/MultiSpriteSuperChip.s"

;; CRITICAL: Define bscode_length before any code that uses it
;; Match actual 64kSC bankswitch stub size (see Tools/batariBASIC/includes/banksw.asm ;size=42)
;; $2A = 42 bytes, so bankswitch code runs right up to $FFE0 before EFSC header
;; Use = instead of EQU so ifconst can detect it
;; Define unconditionally - if already defined, this will be ignored by assembler
bscode_length = $2A

;; CRITICAL: Define base variables (var0-var48, a-z) BEFORE redefs file
;; The Makefile inserts include "2600basic_variable_redefs.h" early (after processor 6502),
;; so base variables must be defined before that point
;; Multisprite memory layout (from multisprite.h)
;; Note: These are also defined in MultiSpriteSuperChip.s, but we keep them here
;; for compatibility and to ensure they&rsquo;re defined before the redefs file
var0 = $A4
var1 = $A5
var2 = $A6
var3 = $A7
var4 = $A8
var5 = $A9
var6 = $AA
var7 = $AB
var8 = $AC
var9 = $AD
var10 = $AE
var11 = $AF
var12 = $B0
var13 = $B1
var14 = $B2
var15 = $B3
var16 = $B4
var17 = $B5
var18 = $B6
var19 = $B7
var20 = $B8
var21 = $B9
var22 = $BA
var23 = $BB
var24 = $BC
var25 = $BD
var26 = $BE
var27 = $BF
var28 = $C0
var29 = $C1
var30 = $C2
var31 = $C3
var32 = $C4
var33 = $C5
var34 = $C6
var35 = $C7
var36 = $C8
var37 = $C9
var38 = $CA
var39 = $CB
var40 = $CC
var41 = $CD
var42 = $CE
var43 = $CF
var44 = $D0
var45 = $D1
var46 = $D2
var47 = $D3
;; var48-var127 don't exist - SuperChip RAM accessed via r000-r127/w000-w127 only
;; playerCharacter is now in SCRAM (w111-w114), defined in Variables.bas
;; Multisprite letter variables (different addresses than standard batariBASIC)
;; Note: These are also defined in MultiSpriteSuperChip.s, but we keep them here
;; for compatibility and to ensure they’re defined before the redefs file
A = $d7
a = $d7
B = $d8
b = $d8
C = $d9
c = $d9
D = $da
d = $da
E = $db
e = $db
F = $dc
f = $dc
G = $dd
g = $dd
H = $de
h = $de
I = $df
i = $df
J = $e0
j = $e0
K = $e1
k = $e1
L = $e2
l = $e2
M = $e3
m = $e3
N = $e4
n = $e4
O = $e5
o = $e5
P = $e6
p = $e6
Q = $e7
q = $e7
R = $e8
r = $e8
S = $e9
s = $e9
T = $ea
t = $ea
U = $eb
u = $eb
V = $ec
v = $ec
W = $ed
w = $ed
X = $ee
x = $ee
Y = $ef
y = $ef
Z = $f0
z = $f0
end

#include "Source/Common/Colors.h"
#include "Source/Common/Constants.bas"
#include "Source/Common/Enums.bas"
#include "Source/Common/Macros.bas"
#include "Source/Common/Variables.bas"