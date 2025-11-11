; ChaosFight combined multisprite + superchip header.
; Provides the 2600basic variable map alongside the multisprite kernel aliases
; so DASM receives a single, consistent definition set.
; Licensed under CC0 to match upstream batariBASIC headers.

; --- Multisprite workspace remapping ----------------------------------------
; Re-apply the multisprite kernel layout using SET so symbols from 2600basic.h
; are reassigned without triggering EQU conflicts under modern DASM.

missile0x         SET $80
missile1x         SET $81
ballx             SET $82

; multisprite bookkeeping (5 bytes per sprite set)
SpriteIndex       SET $83

player0x          SET $84
NewSpriteX        SET $85   ; X position for multiplexed sprites
player1x          SET $85
player2x          SET $86
player3x          SET $87
player4x          SET $88
player5x          SET $89

objecty           SET $8A
missile0y         SET $8A
missile1y         SET $8B
bally             SET $8C

player0y          SET $8D
NewSpriteY        SET $8E   ; Y position for multiplexed sprites
player1y          SET $8E
player2y          SET $8F
player3y          SET $90
player4y          SET $91
player5y          SET $92

NewNUSIZ          SET $93
_NUSIZ1           SET $93
NUSIZ2            SET $94
NUSIZ3            SET $95
NUSIZ4            SET $96
NUSIZ5            SET $97

NewCOLUP1         SET $98
_COLUP1           SET $98
COLUP2            SET $99
COLUP3            SET $9A
COLUP4            SET $9B
COLUP5            SET $9C

SpriteGfxIndex    SET $9D

player0pointer    SET $A2
player0pointerlo  SET $A2
player0pointerhi  SET $A3

;P0Top = temp5 in original kernel; use a hard value to avoid dasm issues.
P0Top             SET $CF
P0Bottom          SET $A4
P1Bottom          SET $A5

player1pointerlo  SET $A6
player2pointerlo  SET $A7
player3pointerlo  SET $A8
player4pointerlo  SET $A9
player5pointerlo  SET $AA

player1pointerhi  SET $AB
player2pointerhi  SET $AC
player3pointerhi  SET $AD
player4pointerhi  SET $AE
player5pointerhi  SET $AF

player0height     SET $B0
spriteheight      SET $B1   ; heights of multiplexed player sprite
player1height     SET $B1
player2height     SET $B2
player3height     SET $B3
player4height     SET $B4
player5height     SET $B5

PF1temp1          SET $B6
PF1temp2          SET $B7
PF2temp1          SET $B8
PF2temp2          SET $B9

pfpixelheight     SET $BA

; playfield pointers now reference sprite data
playfield         SET $BB
PF1pointer        SET $BB
PF2pointer        SET $BD

statusbarlength   SET $BF
aux3              SET $BF

lifecolor         SET $C0
pfscorecolor      SET $C0
aux4              SET $C0

; P1display reused for kernel bookkeeping (hard-coded to avoid dasm issues)
P1display         SET $CC
lifepointer       SET $C1
lives             SET $C2
pfscore1          SET $C1
pfscore2          SET $C2
aux5              SET $C1
aux6              SET $C2

playfieldpos      SET $C3

; RepoLine reused for multisprite bookkeeping
RepoLine          SET $CE

pfheight          SET $C4
scorepointers     SET $C5

temp1             SET $CB   ; kernel temps are relocated for multisprite
temp2             SET $CC
temp3             SET $CD
temp4             SET $CE
temp5             SET $CF
temp6             SET $D0
temp7             SET $D1   ; used to aid in bankswitching

score             SET $D2
scorecolor        SET $D5   ; relocated to preserve kernel workspace
rand              SET $D6

A                 SET $D7
a                 SET $D7
B                 SET $D8
b                 SET $D8
C                 SET $D9
c                 SET $D9
D                 SET $DA
d                 SET $DA
E                 SET $DB
e                 SET $DB
F                 SET $DC
f                 SET $DC
G                 SET $DD
g                 SET $DD
H                 SET $DE
h                 SET $DE
I                 SET $DF
i                 SET $DF
J                 SET $E0
j                 SET $E0
K                 SET $E1
k                 SET $E1
L                 SET $E2
l                 SET $E2
M                 SET $E3
m                 SET $E3
N                 SET $E4
n                 SET $E4
O                 SET $E5
o                 SET $E5
P                 SET $E6
p                 SET $E6
Q                 SET $E7
q                 SET $E7
R                 SET $E8
r                 SET $E8
S                 SET $E9
s                 SET $E9
T                 SET $EA
t                 SET $EA
U                 SET $EB
u                 SET $EB
V                 SET $EC
v                 SET $EC
W                 SET $ED
w                 SET $ED
X                 SET $EE
x                 SET $EE
Y                 SET $EF
y                 SET $EF
Z                 SET $F0
z                 SET $F0

spritesort        SET $F1
spritesort2       SET $F2
spritesort3       SET $F3
spritesort4       SET $F4
spritesort5       SET $F5

stack1            SET $F6
stack2            SET $F7
stack3            SET $F8
stack4            SET $F9

