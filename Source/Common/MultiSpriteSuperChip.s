; ChaosFight combined multisprite + superchip header.
; Provides the 2600basic variable map alongside the multisprite kernel aliases
; so DASM receives a single, consistent definition set without pulling in the
; upstream multisprite.h or superchip.h files.
; Licensed under CC0 to match upstream batariBASIC headers.
;
; --- Multisprite workspace remapping ----------------------------------------
;
missile0x        EQU $80
missile1x        EQU $81
ballx            EQU $82
SpriteIndex      EQU $83
player0x         EQU $84
NewSpriteX       EQU $85
player1x         EQU $85
player2x         EQU $86
player3x         EQU $87
player4x         EQU $88
player5x         EQU $89
objecty          EQU $8A
missile0y        EQU $8A
missile1y        EQU $8B
missile1height   EQU $87
player1color     EQU $87
bally            EQU $8C
player0y         EQU $8D
NewSpriteY       EQU $8E
player1y         EQU $8E
player2y         EQU $8F
player3y         EQU $90
player4y         EQU $91
player5y         EQU $92
missile0height   EQU $90
ballheight       EQU $92
currentpaddle    EQU $90
paddle           EQU $91
player0colorstore EQU $82
player0color     EQU $90
NewNUSIZ         EQU $93
_NUSIZ1          EQU $93
NUSIZ2           EQU $94
NUSIZ3           EQU $95
NUSIZ4           EQU $96
NUSIZ5           EQU $97
NewCOLUP1        EQU $98
_COLUP1          EQU $98
COLUP2           EQU $99
COLUP3           EQU $9A
COLUP4           EQU $9B
COLUP5           EQU $9C
SpriteGfxIndex   EQU $9D
player0pointer   EQU $A2
player0pointerlo EQU $A2
player0pointerhi EQU $A3
P0Top            EQU $CF
P0Bottom         EQU $A4
P1Bottom         EQU $A5
player1pointerlo EQU $A6
player2pointerlo EQU $A7
player3pointerlo EQU $A8
player4pointerlo EQU $A9
player5pointerlo EQU $AA
player1pointerhi EQU $AB
player2pointerhi EQU $AC
player3pointerhi EQU $AD
player4pointerhi EQU $AE
player5pointerhi EQU $AF
player0height    EQU $B0
spriteheight     EQU $B1
player1height    EQU $B1
player2height    EQU $B2
player3height    EQU $B3
player4height    EQU $B4
player5height    EQU $B5
player9height    EQU $BC
PF1temp1         EQU $B6
PF1temp2         EQU $B7
PF2temp1         EQU $B8
PF2temp2         EQU $B9
pfpixelheight    EQU $BA
playfield        EQU $BB
PF1pointer       EQU $BB
PF2pointer       EQU $BD
statusbarlength  EQU $BF
aux3             EQU $BF
lifecolor        EQU $C0
pfscorecolor     EQU $C0
aux4             EQU $C0
aux1             EQU $F0
aux2             EQU $F1
pfcolortable     EQU $F0
pfheighttable    EQU $F0
playfieldpos     EQU $C3
RepoLine         EQU $CE
pfheight         EQU $C4
scorepointers    EQU $C5
P1display        EQU $CC
lifepointer      EQU $C1
lives            EQU $C2
pfscore1         EQU $C1
pfscore2         EQU $C2
aux5             EQU $C1
aux6             EQU $C2
temp1            EQU $CB
temp2            EQU $CC
temp3            EQU $CD
temp4            EQU $CE
temp5            EQU $CF
temp6            EQU $D0
temp7            EQU $D1
score            EQU $D2
qtcontroller     EQU $E7
scorecolor       EQU $D5
rand             EQU $D6
spritesort       EQU $F1
spritesort2      EQU $F2
spritesort3      EQU $F3
spritesort4      EQU $F4
spritesort5      EQU $F5
stack1           EQU $F6
stack2           EQU $F7
stack3           EQU $F8
stack4           EQU $F9
;
; --- Zero-page utility aliases ---------------------------------------------
;
var0             EQU $A4
var1             EQU $A5
var2             EQU $A6
var3             EQU $A7
var4             EQU $A8
var5             EQU $A9
var6             EQU $AA
var7             EQU $AB
var8             EQU $AC
var9             EQU $AD
var10            EQU $AE
var11            EQU $AF
var12            EQU $B0
var13            EQU $B1
var14            EQU $B2
var15            EQU $B3
var16            EQU $B4
var17            EQU $B5
var18            EQU $B6
var19            EQU $B7
var20            EQU $B8
var21            EQU $B9
var22            EQU $BA
var23            EQU $BB
var24            EQU $BC
var25            EQU $BD
var26            EQU $BE
var27            EQU $BF
var28            EQU $C0
var29            EQU $C1
var30            EQU $C2
var31            EQU $C3
var32            EQU $C4
var33            EQU $C5
var34            EQU $C6
var35            EQU $C7
var36            EQU $C8
var37            EQU $C9
var38            EQU $CA
var39            EQU $CB
var40            EQU $CC
var41            EQU $CD
var42            EQU $CE
var43            EQU $CF
var44            EQU $D0
var45            EQU $D1
var46            EQU $D2
var47            EQU $D3
pfrowheight      EQU $D4
pfrows           EQU $D5
pfscore          EQU 1    ; Enable playfield score feature
noscore          EQU 0    ; Enable score display (health bars)

playfieldRow     EQU $5C  ; Playfield row variable (user-defined)

pfread                        ; Playfield read function
        rts

minikernel                    ; Titlescreen minikernel subroutine
        rts

mk_score_on      EQU 1    ; Enable score minikernel
mk_gameselect_on EQU 1    ; Enable gameselect minikernel

mincycles        EQU $E8  ; Minimum cycles variable

font             EQU 0    ; Default font style

debugscore       EQU 0    ; Disable debug score display

; Titlescreen minikernel colors
bmp_48x2_1_background EQU $00
bmp_48x2_2_background EQU $00
bmp_48x2_3_background EQU $00
bmp_48x2_4_background EQU $00
bmp_48x2_1_PF1 EQU $00
bmp_48x2_1_PF2 EQU $00
bmp_48x2_2_PF1 EQU $00
bmp_48x2_2_PF2 EQU $00
bmp_48x2_3_PF1 EQU $00
bmp_48x2_3_PF2 EQU $00
bmp_48x2_4_PF1 EQU $00
bmp_48x2_4_PF2 EQU $00

A                EQU $D7
a                EQU $D7
B                EQU $D8
b                EQU $D8
C                EQU $D9
c                EQU $D9
D                EQU $DA
d                EQU $DA
E                EQU $DB
e                EQU $DB
F                EQU $DC
f                EQU $DC
G                EQU $DD
g                EQU $DD
H                EQU $DE
h                EQU $DE
I                EQU $DF
i                EQU $DF
J                EQU $E0
j                EQU $E0
K                EQU $E1
k                EQU $E1
L                EQU $E2
l                EQU $E2
M                EQU $E3
m                EQU $E3
N                EQU $E4
n                EQU $E4
O                EQU $E5
o                EQU $E5
P                EQU $E6
p                EQU $E6
Q                EQU $E7
q                EQU $E7
R                EQU $E8
r                EQU $E8
S                EQU $E9
s                EQU $E9
T                EQU $EA
t                EQU $EA
U                EQU $EB
u                EQU $EB
V                EQU $EC
v                EQU $EC
W                EQU $ED
w                EQU $ED
X                EQU $EE
x                EQU $EE
Y                EQU $EF
y                EQU $EF
Z                EQU $F0
z                EQU $F0
;
; --- Superchip RAM mapping --------------------------------------------------
;
write_RAM        EQU $F000
wRAM             EQU $F000
w000             EQU $F000
w001             EQU $F001
w002             EQU $F002
w003             EQU $F003
w004             EQU $F004
w005             EQU $F005
w006             EQU $F006
w007             EQU $F007
w008             EQU $F008
w009             EQU $F009
w010             EQU $F00A
w011             EQU $F00B
w012             EQU $F00C
w013             EQU $F00D
w014             EQU $F00E
w015             EQU $F00F
w016             EQU $F010
w017             EQU $F011
w018             EQU $F012
w019             EQU $F013
w020             EQU $F014
w021             EQU $F015
w022             EQU $F016
w023             EQU $F017
w024             EQU $F018
w025             EQU $F019
w026             EQU $F01A
w027             EQU $F01B
w028             EQU $F01C
w029             EQU $F01D
w030             EQU $F01E
w031             EQU $F01F
w032             EQU $F020
w033             EQU $F021
w034             EQU $F022
w035             EQU $F023
w036             EQU $F024
w037             EQU $F025
w038             EQU $F026
w039             EQU $F027
w040             EQU $F028
w041             EQU $F029
w042             EQU $F02A
w043             EQU $F02B
w044             EQU $F02C
w045             EQU $F02D
w046             EQU $F02E
w047             EQU $F02F
w048             EQU $F030
w049             EQU $F031
w050             EQU $F032
w051             EQU $F033
w052             EQU $F034
w053             EQU $F035
w054             EQU $F036
w055             EQU $F037
w056             EQU $F038
w057             EQU $F039
w058             EQU $F03A
w059             EQU $F03B
w060             EQU $F03C
w061             EQU $F03D
w062             EQU $F03E
w063             EQU $F03F
w064             EQU $F040
w065             EQU $F041
w066             EQU $F042
w067             EQU $F043
w068             EQU $F044
w069             EQU $F045
w070             EQU $F046
w071             EQU $F047
w072             EQU $F048
w073             EQU $F049
w074             EQU $F04A
w075             EQU $F04B
w076             EQU $F04C
w077             EQU $F04D
w078             EQU $F04E
w079             EQU $F04F
w080             EQU $F050
w081             EQU $F051
w082             EQU $F052
w083             EQU $F053
w084             EQU $F054
w085             EQU $F055
w086             EQU $F056
w087             EQU $F057
w088             EQU $F058
w089             EQU $F059
w090             EQU $F05A
w091             EQU $F05B
w092             EQU $F05C
w093             EQU $F05D
w094             EQU $F05E
w095             EQU $F05F
w096             EQU $F060
w097             EQU $F061
w098             EQU $F062
w099             EQU $F063
w100             EQU $F064
w101             EQU $F065
w102             EQU $F066
w103             EQU $F067
w104             EQU $F068
w105             EQU $F069
w106             EQU $F06A
w107             EQU $F06B
w108             EQU $F06C
w109             EQU $F06D
w110             EQU $F06E
w111             EQU $F06F
w112             EQU $F070
w113             EQU $F071
w114             EQU $F072
w115             EQU $F073
w116             EQU $F074
w117             EQU $F075
w118             EQU $F076
w119             EQU $F077
w120             EQU $F078
w121             EQU $F079
w122             EQU $F07A
w123             EQU $F07B
w124             EQU $F07C
w125             EQU $F07D
w126             EQU $F07E
w127             EQU $F07F
read_RAM         EQU $F080
rRAM             EQU $F080
r000             EQU $F080
r001             EQU $F081
r002             EQU $F082
r003             EQU $F083
r004             EQU $F084
r005             EQU $F085
r006             EQU $F086
r007             EQU $F087
r008             EQU $F088
r009             EQU $F089
r010             EQU $F08A
r011             EQU $F08B
r012             EQU $F08C
r013             EQU $F08D
r014             EQU $F08E
r015             EQU $F08F
r016             EQU $F090
r017             EQU $F091
r018             EQU $F092
r019             EQU $F093
r020             EQU $F094
r021             EQU $F095
r022             EQU $F096
r023             EQU $F097
r024             EQU $F098
r025             EQU $F099
r026             EQU $F09A
r027             EQU $F09B
r028             EQU $F09C
r029             EQU $F09D
r030             EQU $F09E
r031             EQU $F09F
r032             EQU $F0A0
r033             EQU $F0A1
r034             EQU $F0A2
r035             EQU $F0A3
r036             EQU $F0A4
r037             EQU $F0A5
r038             EQU $F0A6
r039             EQU $F0A7
r040             EQU $F0A8
r041             EQU $F0A9
r042             EQU $F0AA
r043             EQU $F0AB
r044             EQU $F0AC
r045             EQU $F0AD
r046             EQU $F0AE
r047             EQU $F0AF
r048             EQU $F0B0
r049             EQU $F0B1
r050             EQU $F0B2
r051             EQU $F0B3
r052             EQU $F0B4
r053             EQU $F0B5
r054             EQU $F0B6
r055             EQU $F0B7
r056             EQU $F0B8
r057             EQU $F0B9
r058             EQU $F0BA
r059             EQU $F0BB
r060             EQU $F0BC
r061             EQU $F0BD
r062             EQU $F0BE
r063             EQU $F0BF
r064             EQU $F0C0
r065             EQU $F0C1
r066             EQU $F0C2
r067             EQU $F0C3
r068             EQU $F0C4
r069             EQU $F0C5
r070             EQU $F0C6
r071             EQU $F0C7
r072             EQU $F0C8
r073             EQU $F0C9
r074             EQU $F0CA
r075             EQU $F0CB
r076             EQU $F0CC
r077             EQU $F0CD
r078             EQU $F0CE
r079             EQU $F0CF
r080             EQU $F0D0
r081             EQU $F0D1
r082             EQU $F0D2
r083             EQU $F0D3
r084             EQU $F0D4
r085             EQU $F0D5
r086             EQU $F0D6
r087             EQU $F0D7
r088             EQU $F0D8
r089             EQU $F0D9
r090             EQU $F0DA
r091             EQU $F0DB
r092             EQU $F0DC
r093             EQU $F0DD
r094             EQU $F0DE
r095             EQU $F0DF
r096             EQU $F0E0
r097             EQU $F0E1
r098             EQU $F0E2
r099             EQU $F0E3
r100             EQU $F0E4
r101             EQU $F0E5
r102             EQU $F0E6
r103             EQU $F0E7
r104             EQU $F0E8
r105             EQU $F0E9
r106             EQU $F0EA
r107             EQU $F0EB
r108             EQU $F0EC
r109             EQU $F0ED
r110             EQU $F0EE
r111             EQU $F0EF
r112             EQU $F0F0
r113             EQU $F0F1
r114             EQU $F0F2
r115             EQU $F0F3
r116             EQU $F0F4
r117             EQU $F0F5
r118             EQU $F0F6
r119             EQU $F0F7
r120             EQU $F0F8
r121             EQU $F0F9
r122             EQU $F0FA
r123             EQU $F0FB
r124             EQU $F0FC
r125             EQU $F0FD
r126             EQU $F0FE
r127             EQU $F0FF
;
; --- Optional kernel subroutines --------------------------------------------
;
vblank_bB_code                    ; Dummy - not used in this game
        rts

switchbw        EQU $0282         ; Console switches register (SWCHB)

        ; Screen dimensions
screenheight     EQU 192          ; NTSC screen height

        ; Random number variables
rand16           EQU $F2           ; 16-bit random number (2 bytes: $F2-$F3)
;
; --- Kernel helper macros ---------------------------------------------------
;
        MAC   RETURN
           ifnconst bankswitch
             rts
           else
             jmp BS_return
           endif
        ENDM

 include "2600basic_variable_redefs.h"
