; ChaosFight superchip RAM definitions and ChaosFight-specific additions.
; The upstream multisprite definitions are included separately.
; NOTE: processor 6502 directive is in AssemblyConfig.bas, not here

#include "vcs.h"
#include "macro.h"
; Issue #930: Ensure every SuperChip SCRAM port symbol is exported here so
; cross-bank routines rely on one authoritative header.
; CRITICAL: Define standard batariBASIC and multisprite symbols BEFORE redefs file
; Multisprite kernel uses different addresses than standard batariBASIC (see multisprite.h)
; Standard TIA/RIOT registers (multisprite layout from multisprite.h)
missile0x = $80
missile1x = $81
ballx = $82
SpriteIndex = $83
player0x = $84
NewSpriteX = $85
player1x = $85
player2x = $86
player3x = $87
player4x = $88
player5x = $89
objecty = $8A
missile0y = $8A
missile1y = $8B
bally = $8C
player0y = $8D
NewSpriteY = $8E
player1y = $8E
player2y = $8F
player3y = $90
player4y = $91
player5y = $92
NewNUSIZ = $93
_NUSIZ1 = $93
NUSIZ2 = $94
NUSIZ3 = $95
NUSIZ4 = $96
NUSIZ5 = $97
NewCOLUP1 = $98
_COLUP1 = $98
COLUP2 = $99
COLUP3 = $9A
COLUP4 = $9B
COLUP5 = $9C
SpriteGfxIndex = $9D
aux2 = $F1
pfcolortable = $F0
player0pointer = $A2
player0pointerlo = $A2
player0pointerhi = $A3
P0Top = $CF
P0Bottom = $A4
P1Bottom = $A5
player1pointerlo = $A6
player2pointerlo = $A7
player3pointerlo = $A8
player4pointerlo = $A9
player5pointerlo = $AA
player1pointerhi = $AB
player2pointerhi = $AC
player3pointerhi = $AD
player4pointerhi = $AE
player5pointerhi = $AF
player0height = $B0
spriteheight = $B1
player1height = $B1
player2height = $B2
player3height = $B3
player4height = $B4
player5height = $B5
PF1temp1 = $B6
PF1temp2 = $B7
PF2temp1 = $B8
PF2temp2 = $B9
pfpixelheight = $BA
playfield = $BB
PF1pointer = $BB
PF2pointer = $BD
statusbarlength = $BF
aux3 = $BF
lifecolor = $C0
pfscorecolor = $C0
aux4 = $C0
P1display = $cc
lifepointer = $c1
lives = $c2
pfscore1 = $c1
pfscore2 = $c2
aux5 = $c1
aux6 = $c2
playfieldpos = $C3
RepoLine = $ce
pfheight = $C4
scorepointers = $C5
; Multisprite temp variables (different addresses than standard batariBASIC)
temp1 = $CB
temp2 = $CC
temp3 = $CD
temp4 = $CE
temp5 = $CF
temp6 = $D0
temp7 = $D1
score = $D2
scorecolor = $D5
rand = $D6
; Multisprite letter variables (different addresses than standard batariBASIC)
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
spritesort = $f1
spritesort2 = $f2
spritesort3 = $f3
spritesort4 = $f4
spritesort5 = $f5
stack1 = $f6
stack2 = $f7
stack3 = $f8
stack4 = $f9
; Compile-time constants (from MS_ASSIGN macros, but defined unconditionally here)
player9height = $BC
pfscore = 1
pfrowheight = 16
screenheight = 192
; Additional compile-time constants for kernel and system
noscore = 0
mk_score_on = 1
NO_ILLEGAL_OPCODES = 0
minikernel = 0
ECHOFIRST = 0
switchbw = $0282
; Note: NOT is a batariBASIC keyword (bitwise NOT operator), not a constant
; Compile-time constants (playfield dimensions)
pfrows = 8
; Note: Multisprite kernel uses different memory layout than standard batariBASIC
; The definitions above match multisprite.h, which is the authoritative source
; --- Multisprite compatibility macros ----------------------------------------
; Preserve the RETURN macro expected by multisprite-generated assembly.
; This must be defined early so it is available to all included files.
          MAC   RETURN
          ifnconst bankswitch
          rts
          else
          jmp BS_return
          endif
          ENDM

; CRITICAL: Define base variables (var0-var48) BEFORE redefs file so symbols can resolve
; These MUST be defined unconditionally (not ifnconst) and appear before the redefs include
; Note: Multisprite doesn’t use var0-var48 in the same way as standard batariBASIC,
; but we define them here for compatibility with code that might reference them
; Base variable definitions (var0-var48) - define unconditionally to ensure they exist
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
; Note: var48 and a-z are defined below in multisprite section with different addresses
; Multisprite uses different memory layout - see multisprite letter variables section below
; CRITICAL: Define SuperChip RAM ports (r000-r127, w000-w127) before redefs file
; These are referenced by the redefs file (e.g., r075, w102) and must exist first
; Write ports (w000-w127 at $F000-$F07F)
w000 = $F000
w001 = $F001
w002 = $F002
w003 = $F003
w004 = $F004
w005 = $F005
w006 = $F006
w007 = $F007
w008 = $F008
w009 = $F009
w010 = $F00A
w011 = $F00B
w012 = $F00C
w013 = $F00D
w014 = $F00E
w015 = $F00F
w016 = $F010
w017 = $F011
w018 = $F012
w019 = $F013
w020 = $F014
w021 = $F015
w022 = $F016
w023 = $F017
w024 = $F018
w025 = $F019
w026 = $F01A
w027 = $F01B
w028 = $F01C
w029 = $F01D
w030 = $F01E
w031 = $F01F
w032 = $F020
w033 = $F021
w034 = $F022
w035 = $F023
w036 = $F024
w037 = $F025
w038 = $F026
w039 = $F027
w040 = $F028
w041 = $F029
w042 = $F02A
w043 = $F02B
w044 = $F02C
w045 = $F02D
w046 = $F02E
w047 = $F02F
w048 = $F030
w049 = $F031
w050 = $F032
w051 = $F033
w052 = $F034
w053 = $F035
w054 = $F036
w055 = $F037
w056 = $F038
w057 = $F039
w058 = $F03A
w059 = $F03B
w060 = $F03C
w061 = $F03D
w062 = $F03E
w063 = $F03F
w064 = $F040
w065 = $F041
w066 = $F042
w067 = $F043
w068 = $F044
w069 = $F045
w070 = $F046
w071 = $F047
w072 = $F048
w073 = $F049
w074 = $F04A
w075 = $F04B
w076 = $F04C
w077 = $F04D
w078 = $F04E
w079 = $F04F
w080 = $F050
w081 = $F051
w082 = $F052
w083 = $F053
w084 = $F054
w085 = $F055
w086 = $F056
w087 = $F057
w088 = $F058
w089 = $F059
w090 = $F05A
w091 = $F05B
w092 = $F05C
w093 = $F05D
w094 = $F05E
w095 = $F05F
w096 = $F060
w097 = $F061
w098 = $F062
w099 = $F063
w100 = $F064
w101 = $F065
w102 = $F066
w103 = $F067
w104 = $F068
w105 = $F069
w106 = $F06A
w107 = $F06B
w108 = $F06C
w109 = $F06D
w110 = $F06E
w111 = $F06F
w112 = $F070
w113 = $F071
w114 = $F072
w115 = $F073
w116 = $F074
w117 = $F075
w118 = $F076
w119 = $F077
w120 = $F078
w121 = $F079
w122 = $F07A
w123 = $F07B
w124 = $F07C
w125 = $F07D
w126 = $F07E
w127 = $F07F
; Read ports (r000-r127 at $F080-$F0FF)
r000 = $F080
r001 = $F081
r002 = $F082
r003 = $F083
r004 = $F084
r005 = $F085
r006 = $F086
r007 = $F087
r008 = $F088
r009 = $F089
r010 = $F08A
r011 = $F08B
r012 = $F08C
r013 = $F08D
r014 = $F08E
r015 = $F08F
r016 = $F090
r017 = $F091
r018 = $F092
r019 = $F093
r020 = $F094
r021 = $F095
r022 = $F096
r023 = $F097
r024 = $F098
r025 = $F099
r026 = $F09A
r027 = $F09B
r028 = $F09C
r029 = $F09D
r030 = $F09E
r031 = $F09F
r032 = $F0A0
r033 = $F0A1
r034 = $F0A2
r035 = $F0A3
r036 = $F0A4
r037 = $F0A5
r038 = $F0A6
r039 = $F0A7
r040 = $F0A8
r041 = $F0A9
r042 = $F0AA
r043 = $F0AB
r044 = $F0AC
r045 = $F0AD
r046 = $F0AE
r047 = $F0AF
r048 = $F0B0
r049 = $F0B1
r050 = $F0B2
r051 = $F0B3
r052 = $F0B4
r053 = $F0B5
r054 = $F0B6
r055 = $F0B7
r056 = $F0B8
r057 = $F0B9
r058 = $F0BA
r059 = $F0BB
r060 = $F0BC
r061 = $F0BD
r062 = $F0BE
r063 = $F0BF
r064 = $F0C0
r065 = $F0C1
r066 = $F0C2
r067 = $F0C3
r068 = $F0C4
r069 = $F0C5
r070 = $F0C6
r071 = $F0C7
r072 = $F0C8
r073 = $F0C9
r074 = $F0CA
r075 = $F0CB
r076 = $F0CC
r077 = $F0CD
r078 = $F0CE
r079 = $F0CF
r080 = $F0D0
r081 = $F0D1
r082 = $F0D2
r083 = $F0D3
r084 = $F0D4
r085 = $F0D5
r086 = $F0D6
r087 = $F0D7
r088 = $F0D8
r089 = $F0D9
r090 = $F0DA
r091 = $F0DB
r092 = $F0DC
r093 = $F0DD
r094 = $F0DE
r095 = $F0DF
r096 = $F0E0
r097 = $F0E1
r098 = $F0E2
r099 = $F0E3
r100 = $F0E4
r101 = $F0E5
r102 = $F0E6
r103 = $F0E7
r104 = $F0E8
r105 = $F0E9
r106 = $F0EA
r107 = $F0EB
r108 = $F0EC
r109 = $F0ED
r110 = $F0EE
r111 = $F0EF
r112 = $F0F0
r113 = $F0F1
r114 = $F0F2
r115 = $F0F3
r116 = $F0F4
r117 = $F0F5
r118 = $F0F6
r119 = $F0F7
r120 = $F0F8
r121 = $F0F9
r122 = $F0FA
r123 = $F0FB
r124 = $F0FC
r125 = $F0FD
r126 = $F0FE
r127 = $F0FF
; Use DASM include (not #include) since file is generated by batariBASIC after cpp preprocessing
; Path: 2600basic_variable_redefs.h (relative to Object/ directory where DASM runs with -I. include path)
; Base variables (var0, n, u, etc.) and SuperChip ports (r000-r127, w000-w127) are defined above
; before this include, so they exist when the redefs file references them
          include "2600basic_variable_redefs.h"

; Define compiler constants if not already defined by batariBASIC
; These are forward declarations that may be redefined by batariBASIC’s generated constants
          ifnconst pfres
pfres = 8
          endif
          ifnconst bscode_length
; Match actual 64kSC bankswitch stub size (see Tools/batariBASIC/includes/banksw.asm ;size=42)
; $2A = 42 bytes, so bankswitch code runs right up to $FFE0 before EFSC header
bscode_length = $2A
          endif
          ifnconst multisprite
multisprite = 2
          endif
          ifnconst superchip
superchip = 1
          endif
          ifnconst bankswitch
bankswitch = 64
          endif
          ifnconst bankswitch_hotspot
bankswitch_hotspot = $FFF8
          endif
          ifnconst overscan_time
overscan_time = 36
          endif
          ifnconst vblank_bB_code
vblank_bB_code = $0000
          endif

; Bank boundary definitions for 64K SuperChip ROM (16 banks x 4K each)
; Each bank reserves space for bankswitching code at the end
; Bankswitch code starts at $FE0 - bscode_length in each bank’s ORG space
; BANKN_END = (N-1)*$1000 + $FE0 - bscode_length
          ifconst bscode_length
BANK1_END = $0000 + $FE0 - bscode_length
BANK2_END = $1000 + $FE0 - bscode_length
BANK3_END = $2000 + $FE0 - bscode_length
BANK4_END = $3000 + $FE0 - bscode_length
BANK5_END = $4000 + $FE0 - bscode_length
BANK6_END = $5000 + $FE0 - bscode_length
BANK7_END = $6000 + $FE0 - bscode_length
BANK8_END = $7000 + $FE0 - bscode_length
BANK9_END = $8000 + $FE0 - bscode_length
BANK10_END = $9000 + $FE0 - bscode_length
BANK11_END = $A000 + $FE0 - bscode_length
BANK12_END = $B000 + $FE0 - bscode_length
BANK13_END = $C000 + $FE0 - bscode_length
BANK14_END = $D000 + $FE0 - bscode_length
BANK15_END = $E000 + $FE0 - bscode_length
BANK16_END = $F000 + $FE0 - bscode_length
          else
; Fallback values if bscode_length not yet defined (assumes 32 bytes = $20)
; $FE0 - $20 = $FC0
BANK1_END = $0000 + $FC0
BANK2_END = $1000 + $FC0
BANK3_END = $2000 + $FC0
BANK4_END = $3000 + $FC0
BANK5_END = $4000 + $FC0
BANK6_END = $5000 + $FC0
BANK7_END = $6000 + $FC0
BANK8_END = $7000 + $FC0
BANK9_END = $8000 + $FC0
BANK10_END = $9000 + $FC0
BANK11_END = $A000 + $FC0
BANK12_END = $B000 + $FC0
BANK13_END = $C000 + $FC0
BANK14_END = $D000 + $FC0
BANK15_END = $E000 + $FC0
BANK16_END = $F000 + $FC0

; Note: ORG/RORG and repeat block removed - these cause issues when included
; in batariBASIC asm blocks. The variable definitions below don’t require
; these directives.
; ORG $0000
; RORG $F000
; repeat 256
; .byte $ff
; repend

; ChaosFight combined multisprite + superchip header.
; Provides the 2600basic variable map alongside the multisprite kernel aliases
; so DASM receives a single, consistent definition set.
; Licensed under CC0 to match upstream batariBASIC headers.
;
; --- Helper macro -----------------------------------------------------------
; Guarantee that every symbol is exported to the DASM symbol table while still
; permitting reassignment when upstream headers predefine it.
;
          MAC   MS_ASSIGN 
          ifnconst {1}
{1}     = {2}
          else
{1}     SET {2}
          endif
          ENDM
;
; --- Multisprite workspace remapping ----------------------------------------
; Re-apply the multisprite kernel layout while keeping symbols exported.
;
          MS_ASSIGN  missile0x, $80
          MS_ASSIGN  missile1x, $81
          MS_ASSIGN  ballx, $82

; multisprite bookkeeping (5 bytes per sprite set)
          MS_ASSIGN  SpriteIndex, $83

          MS_ASSIGN  player0x, $84
; X position for multiplexed sprites
          MS_ASSIGN  NewSpriteX, $85
          MS_ASSIGN  player1x, $85
          MS_ASSIGN  player2x, $86
          MS_ASSIGN  player3x, $87
          MS_ASSIGN  player4x, $88
          MS_ASSIGN  player5x, $89

          MS_ASSIGN  objecty, $8A
          MS_ASSIGN  missile0y, $8A
          MS_ASSIGN  missile1y, $8B
          MS_ASSIGN  bally, $8C

          MS_ASSIGN  player0y, $8D
; Y position for multiplexed sprites
          MS_ASSIGN  NewSpriteY, $8E
          MS_ASSIGN  player1y, $8E
          MS_ASSIGN  player2y, $8F
          MS_ASSIGN  player3y, $90
          MS_ASSIGN  player4y, $91
          MS_ASSIGN  player5y, $92

          MS_ASSIGN  NewNUSIZ, $93
          MS_ASSIGN  _NUSIZ1, $93
          MS_ASSIGN  NUSIZ2, $94
          MS_ASSIGN  NUSIZ3, $95
          MS_ASSIGN  NUSIZ4, $96
          MS_ASSIGN  NUSIZ5, $97

          MS_ASSIGN  NewCOLUP1, $98
          MS_ASSIGN  _COLUP1, $98
          MS_ASSIGN  COLUP2, $99
          MS_ASSIGN  COLUP3, $9A
          MS_ASSIGN  COLUP4, $9B
          MS_ASSIGN  COLUP5, $9C

          MS_ASSIGN  SpriteGfxIndex, $9D

          MS_ASSIGN  player0pointer, $A2
          MS_ASSIGN  player0pointerlo, $A2
          MS_ASSIGN  player0pointerhi, $A3

; P0Top = temp5 in original kernel; use a hard value to avoid dasm issues.
          MS_ASSIGN  P0Top, $CF
          MS_ASSIGN  P0Bottom, $A4
          MS_ASSIGN  P1Bottom, $A5

          MS_ASSIGN  player1pointerlo, $A6
          MS_ASSIGN  player2pointerlo, $A7
          MS_ASSIGN  player3pointerlo, $A8
          MS_ASSIGN  player4pointerlo, $A9
          MS_ASSIGN  player5pointerlo, $AA

          MS_ASSIGN  player1pointerhi, $AB
          MS_ASSIGN  player2pointerhi, $AC
          MS_ASSIGN  player3pointerhi, $AD
          MS_ASSIGN  player4pointerhi, $AE
          MS_ASSIGN  player5pointerhi, $AF

          MS_ASSIGN  player0height, $B0
; heights of multiplexed player sprite
          MS_ASSIGN  spriteheight, $B1
          MS_ASSIGN  player1height, $B1
          MS_ASSIGN  player2height, $B2
          MS_ASSIGN  player3height, $B3
          MS_ASSIGN  player4height, $B4
          MS_ASSIGN  player5height, $B5

          MS_ASSIGN  PF1temp1, $B6
          MS_ASSIGN  PF1temp2, $B7
          MS_ASSIGN  PF2temp1, $B8
          MS_ASSIGN  PF2temp2, $B9

          MS_ASSIGN  pfpixelheight, $BA

; playfield pointers now reference sprite data
          MS_ASSIGN  playfield, $BB
          MS_ASSIGN  PF1pointer, $BB
          MS_ASSIGN  PF2pointer, $BD

          MS_ASSIGN  statusbarlength, $BF
          MS_ASSIGN  aux3, $BF

          MS_ASSIGN  lifecolor, $C0
          MS_ASSIGN  pfscorecolor, $C0
          MS_ASSIGN  aux4, $C0

; P1display reused for multisprite bookkeeping (hard-coded to avoid dasm issues)
          MS_ASSIGN  P1display, $CC
          MS_ASSIGN  lifepointer, $C1
          MS_ASSIGN  lives, $C2
          MS_ASSIGN  pfscore1, $C1
          MS_ASSIGN  pfscore2, $C2
          MS_ASSIGN  aux5, $C1
          MS_ASSIGN  aux6, $C2

          MS_ASSIGN  playfieldpos, $C3

; RepoLine reused for multisprite bookkeeping
          MS_ASSIGN  RepoLine, $CE

          MS_ASSIGN  pfheight, $C4
          MS_ASSIGN  scorepointers, $C5

; kernel temps are relocated for multisprite
          MS_ASSIGN  temp1, $CB
          MS_ASSIGN  temp2, $CC
          MS_ASSIGN  temp3, $CD
          MS_ASSIGN  temp4, $CE
          MS_ASSIGN  temp5, $CF
          MS_ASSIGN  temp6, $D0
; used to aid in bankswitching
          MS_ASSIGN  temp7, $D1

          MS_ASSIGN  score, $D2
; relocated to preserve kernel workspace
          MS_ASSIGN  scorecolor, $D5
          MS_ASSIGN  rand, $D6

          MS_ASSIGN  A, $D7
          MS_ASSIGN  a, $D7
          MS_ASSIGN  B, $D8
          MS_ASSIGN  b, $D8
          MS_ASSIGN  C, $D9
          MS_ASSIGN  c, $D9
          MS_ASSIGN  D, $DA
          MS_ASSIGN  d, $DA
          MS_ASSIGN  E, $DB
          MS_ASSIGN  e, $DB
          MS_ASSIGN  F, $DC
          MS_ASSIGN  f, $DC
          MS_ASSIGN  G, $DD
          MS_ASSIGN  g, $DD
          MS_ASSIGN  H, $DE
          MS_ASSIGN  h, $DE
          MS_ASSIGN  I, $DF
          MS_ASSIGN  i, $DF
          MS_ASSIGN  J, $E0
          MS_ASSIGN  j, $E0
          MS_ASSIGN  K, $E1
          MS_ASSIGN  k, $E1
          MS_ASSIGN  L, $E2
          MS_ASSIGN  l, $E2
          MS_ASSIGN  M, $E3
          MS_ASSIGN  m, $E3
          MS_ASSIGN  N, $E4
          MS_ASSIGN  n, $E4
          MS_ASSIGN  O, $E5
          MS_ASSIGN  o, $E5
          MS_ASSIGN  P, $E6
          MS_ASSIGN  p, $E6
          MS_ASSIGN  Q, $E7
          MS_ASSIGN  q, $E7
          MS_ASSIGN  R, $E8
          MS_ASSIGN  r, $E8
          MS_ASSIGN  S, $E9
          MS_ASSIGN  s, $E9
          MS_ASSIGN  T, $EA
          MS_ASSIGN  t, $EA
          MS_ASSIGN  U, $EB
          MS_ASSIGN  u, $EB
          MS_ASSIGN  V, $EC
          MS_ASSIGN  v, $EC
          MS_ASSIGN  W, $ED
          MS_ASSIGN  w, $ED
          MS_ASSIGN  X, $EE
          MS_ASSIGN  x, $EE
          MS_ASSIGN  Y, $EF
          MS_ASSIGN  y, $EF
          MS_ASSIGN  Z, $F0
          MS_ASSIGN  z, $F0

          MS_ASSIGN  spritesort, $F1
          MS_ASSIGN  spritesort2, $F2
          MS_ASSIGN  spritesort3, $F3
          MS_ASSIGN  spritesort4, $F4
          MS_ASSIGN  spritesort5, $F5

          MS_ASSIGN  stack1, $F6
          MS_ASSIGN  stack2, $F7
          MS_ASSIGN  stack3, $F8
          MS_ASSIGN  stack4, $F9

; --- Zero-page utility aliases ------------------------------------------------
          MS_ASSIGN  missile1height, $A4
          MS_ASSIGN  missile0height, $A5
          MS_ASSIGN  ballheight, $92
          MS_ASSIGN  currentpaddle, $90
          MS_ASSIGN  paddle, $91
          MS_ASSIGN  player0colorstore, $82
          MS_ASSIGN  player0color, $90
          MS_ASSIGN  player1color, $87
          MS_ASSIGN  player9height, $BC
          MS_ASSIGN  aux1, $F0
          MS_ASSIGN  aux2, $F1
          MS_ASSIGN  pfcolortable, $F0
          MS_ASSIGN  pfheighttable, $F0

; --- Zero-page variable labels ------------------------------------------------
; Explicit EQU definitions for var variables to ensure DASM can resolve
; zero-page addresses. MS_ASSIGN creates constants, but DASM needs labels
; for zero-page addressing (e.g., STA var42).
; These EQU definitions come before MS_ASSIGN so they take precedence.
var0  EQU $A4
var1  EQU $A5
var2  EQU $A6
var3  EQU $A7
var4  EQU $A8
var5  EQU $A9
var6  EQU $AA
var7  EQU $AB
var8  EQU $AC
var9  EQU $AD
var10 EQU $AE
var11 EQU $AF
var12 EQU $B0
var13 EQU $B1
var14 EQU $B2
var15 EQU $B3
var16 EQU $B4
var17 EQU $B5
var18 EQU $B6
var19 EQU $B7
var20 EQU $B8
var21 EQU $B9
var22 EQU $BA
var23 EQU $BB
var24 EQU $BC
var25 EQU $BD
var26 EQU $BE
var27 EQU $BF
var28 EQU $C0
var29 EQU $C1
var30 EQU $C2
var31 EQU $C3
var32 EQU $C4
var33 EQU $C5
var34 EQU $C6
var35 EQU $C7
var36 EQU $C8
var37 EQU $C9
var38 EQU $CA
var39 EQU $CB
var40 EQU $CC
var41 EQU $CD
var42 EQU $CE
var43 EQU $CF
var44 EQU $D0
var45 EQU $D1
var46 EQU $D2
var47 EQU $D3
; var48-var127 don't exist in multisprite - SuperChip RAM is accessed via r000-r127/w000-w127
; Variable aliases - ensure batariBASIC variable aliases are also assembly labels
; These are defined in Variables.bas as dim aliases, but assembler needs labels
; Use = instead of EQU so it's a label (not just a constant) for indexed addressing
; playerCharacter is now in SCRAM (w111-w114), not zero-page, so no label needed here

          MS_ASSIGN  var0, $A4
          MS_ASSIGN  var1, $A5
          MS_ASSIGN  var2, $A6
          MS_ASSIGN  var3, $A7
          MS_ASSIGN  var4, $A8
          MS_ASSIGN  var5, $A9
          MS_ASSIGN  var6, $AA
          MS_ASSIGN  var7, $AB
          MS_ASSIGN  var8, $AC
          MS_ASSIGN  var9, $AD
          MS_ASSIGN  var10, $AE
          MS_ASSIGN  var11, $AF
          MS_ASSIGN  var12, $B0
          MS_ASSIGN  var13, $B1
          MS_ASSIGN  var14, $B2
          MS_ASSIGN  var15, $B3
          MS_ASSIGN  var16, $B4
          MS_ASSIGN  var17, $B5
          MS_ASSIGN  var18, $B6
          MS_ASSIGN  var19, $B7
          MS_ASSIGN  var20, $B8
          MS_ASSIGN  var21, $B9
          MS_ASSIGN  var22, $BA
          MS_ASSIGN  var23, $BB
          MS_ASSIGN  var24, $BC
          MS_ASSIGN  var25, $BD
          MS_ASSIGN  var26, $BE
          MS_ASSIGN  var27, $BF
          MS_ASSIGN  var28, $C0
          MS_ASSIGN  var29, $C1
          MS_ASSIGN  var30, $C2
          MS_ASSIGN  var31, $C3
          MS_ASSIGN  var32, $C4
          MS_ASSIGN  var33, $C5
          MS_ASSIGN  var34, $C6
          MS_ASSIGN  var35, $C7
          MS_ASSIGN  var36, $C8
          MS_ASSIGN  var37, $C9
          MS_ASSIGN  var38, $CA
          MS_ASSIGN  var39, $CB
          MS_ASSIGN  var40, $CC
          MS_ASSIGN  var41, $CD
          MS_ASSIGN  var42, $CE
          MS_ASSIGN  var43, $CF
          MS_ASSIGN  var44, $D0
          MS_ASSIGN  var45, $D1
          MS_ASSIGN  var46, $D2
          MS_ASSIGN  var47, $D3
          MS_ASSIGN  var48, $D4
          MS_ASSIGN  pfscore, 1
          MS_ASSIGN  noscore, 0
          MS_ASSIGN  ROM2k, 0
          MS_ASSIGN  PXE, 0
          MS_ASSIGN  pfrowheight, 16
          MS_ASSIGN  pfrows, 8

  ; Define debugcycles as a stub label (kernel defines it when debugscore enabled)
  ; MS_ASSIGN would create a constant, but we need a label for jsr debugcycles
  ; This prevents phase errors when debugscore is disabled but jsr debugcycles is generated
  ; NOTE: Moved to end of file to avoid adding byte before data section
  ; Note: debugcycles is defined above as a label, not a constant
  ; This matches the kernel’s usage where jsr debugcycles is called

  ; Forward declarations for batariBASIC built-in variables and routines
  ; These will be defined by batariBASIC compiler/generated code
  ; ECHOFIRST is defined above unconditionally
  ; NOTE: frame is a batariBASIC built-in variable - do not define it here
  ; Standard batariBASIC routines (defined in std_routines.asm, pf_drawing.asm, div_mul.asm)
  ; These are labels, not constants, but we forward-declare them here for symbol resolution
  ; Note: These are actual assembly routines, not variables
  ; randomize, setuppointers, ConvertToBCD, BlankPlayfield, PlayfieldRead, etc.

          MS_ASSIGN  interlaced, 0
          MS_ASSIGN  shakescreen, 0
          MS_ASSIGN  vblank_time, 43
          MS_ASSIGN  scorefade, 0
          MS_ASSIGN  NO_ILLEGAL_OPCODES, 0
          MS_ASSIGN  DPC_kernel_options, 0
          MS_ASSIGN  debugscore, 0
          MS_ASSIGN  legacy, 0
          MS_ASSIGN  readpaddle, 0
          MS_ASSIGN  backgroundchange, 0
          MS_ASSIGN  font, 0
          MS_ASSIGN  mincycles, 232
          MS_ASSIGN  pfcenter, 0
          MS_ASSIGN  FASTFETCH, 0
          MS_ASSIGN  minikernel, 0
          MS_ASSIGN  vertical_reflect, 1
          MS_ASSIGN  no_blank_lines, 0
          MS_ASSIGN  PFmaskvalue, 0
  ; NOT is a batariBASIC keyword (bitwise NOT operator), not a constant - do not define
          MS_ASSIGN  playfieldRow, $5C
          MS_ASSIGN  miniscoretable, $0000
          MS_ASSIGN  gamenumber, $00
          MS_ASSIGN  mk_score_on, 1
          MS_ASSIGN  mk_gameselect_on, 0
          MS_ASSIGN  qtcontroller, $E7
  ; scoretable is defined in Source/Common/ScoreTable.s (replacement for score_graphics.asm)
; NOTE: pfread stub moved to end of file to avoid adding byte before data section

; --- Superchip RAM mapping --------------------------------------------------
; Mirror the standard SuperChip read/write port map so DASM exports every alias.
          MS_ASSIGN  write_RAM, $F000
          MS_ASSIGN  wRAM, $F000
          MS_ASSIGN  w000, $F000
          MS_ASSIGN  w001, $F001
          MS_ASSIGN  w002, $F002
          MS_ASSIGN  w003, $F003
          MS_ASSIGN  w004, $F004
          MS_ASSIGN  w005, $F005
          MS_ASSIGN  w006, $F006
          MS_ASSIGN  w007, $F007
          MS_ASSIGN  w008, $F008
          MS_ASSIGN  w009, $F009
          MS_ASSIGN  w010, $F00A
          MS_ASSIGN  w011, $F00B
          MS_ASSIGN  w012, $F00C
          MS_ASSIGN  w013, $F00D
          MS_ASSIGN  w014, $F00E
          MS_ASSIGN  w015, $F00F
          MS_ASSIGN  w016, $F010
          MS_ASSIGN  w017, $F011
          MS_ASSIGN  w018, $F012
          MS_ASSIGN  w019, $F013
          MS_ASSIGN  w020, $F014
          MS_ASSIGN  w021, $F015
          MS_ASSIGN  w022, $F016
          MS_ASSIGN  w023, $F017
          MS_ASSIGN  w024, $F018
          MS_ASSIGN  w025, $F019
          MS_ASSIGN  w026, $F01A
          MS_ASSIGN  w027, $F01B
          MS_ASSIGN  w028, $F01C
          MS_ASSIGN  w029, $F01D
          MS_ASSIGN  w030, $F01E
          MS_ASSIGN  w031, $F01F
          MS_ASSIGN  w032, $F020
          MS_ASSIGN  w033, $F021
          MS_ASSIGN  w034, $F022
          MS_ASSIGN  w035, $F023
          MS_ASSIGN  w036, $F024
          MS_ASSIGN  w037, $F025
          MS_ASSIGN  w038, $F026
          MS_ASSIGN  w039, $F027
          MS_ASSIGN  w040, $F028
          MS_ASSIGN  w041, $F029
          MS_ASSIGN  w042, $F02A
          MS_ASSIGN  w043, $F02B
          MS_ASSIGN  w044, $F02C
          MS_ASSIGN  w045, $F02D
          MS_ASSIGN  w046, $F02E
          MS_ASSIGN  w047, $F02F
          MS_ASSIGN  w048, $F030
          MS_ASSIGN  w049, $F031
          MS_ASSIGN  w050, $F032
          MS_ASSIGN  w051, $F033
          MS_ASSIGN  w052, $F034
          MS_ASSIGN  w053, $F035
          MS_ASSIGN  w054, $F036
          MS_ASSIGN  w055, $F037
          MS_ASSIGN  w056, $F038
          MS_ASSIGN  w057, $F039
          MS_ASSIGN  w058, $F03A
          MS_ASSIGN  w059, $F03B
          MS_ASSIGN  w060, $F03C
          MS_ASSIGN  w061, $F03D
          MS_ASSIGN  w062, $F03E
          MS_ASSIGN  w063, $F03F
          MS_ASSIGN  w064, $F040
          MS_ASSIGN  w065, $F041
          MS_ASSIGN  w066, $F042
          MS_ASSIGN  w067, $F043
          MS_ASSIGN  w068, $F044
          MS_ASSIGN  w069, $F045
          MS_ASSIGN  w070, $F046
          MS_ASSIGN  w071, $F047
          MS_ASSIGN  w072, $F048
          MS_ASSIGN  w073, $F049
          MS_ASSIGN  w074, $F04A
          MS_ASSIGN  w075, $F04B
          MS_ASSIGN  w076, $F04C
          MS_ASSIGN  w077, $F04D
          MS_ASSIGN  w078, $F04E
          MS_ASSIGN  w079, $F04F
          MS_ASSIGN  w080, $F050
          MS_ASSIGN  w081, $F051
          MS_ASSIGN  w082, $F052
          MS_ASSIGN  w083, $F053
          MS_ASSIGN  w084, $F054
          MS_ASSIGN  w085, $F055
          MS_ASSIGN  w086, $F056
          MS_ASSIGN  w087, $F057
          MS_ASSIGN  w088, $F058
          MS_ASSIGN  w089, $F059
          MS_ASSIGN  w090, $F05A
          MS_ASSIGN  w091, $F05B
          MS_ASSIGN  w092, $F05C
          MS_ASSIGN  w093, $F05D
          MS_ASSIGN  w094, $F05E
          MS_ASSIGN  w095, $F05F
          MS_ASSIGN  w096, $F060
          MS_ASSIGN  w097, $F061
          MS_ASSIGN  w098, $F062
          MS_ASSIGN  w099, $F063
          MS_ASSIGN  w100, $F064
          MS_ASSIGN  w101, $F065
          MS_ASSIGN  w102, $F066
          MS_ASSIGN  w103, $F067
          MS_ASSIGN  w104, $F068
          MS_ASSIGN  w105, $F069
          MS_ASSIGN  w106, $F06A
          MS_ASSIGN  w107, $F06B
          MS_ASSIGN  w108, $F06C
          MS_ASSIGN  w109, $F06D
          MS_ASSIGN  w110, $F06E
          MS_ASSIGN  w111, $F06F
          MS_ASSIGN  w112, $F070
          MS_ASSIGN  w113, $F071
          MS_ASSIGN  w114, $F072
          MS_ASSIGN  w115, $F073
          MS_ASSIGN  w116, $F074
          MS_ASSIGN  w117, $F075
          MS_ASSIGN  w118, $F076
          MS_ASSIGN  w119, $F077
          MS_ASSIGN  w120, $F078
          MS_ASSIGN  w121, $F079
          MS_ASSIGN  w122, $F07A
          MS_ASSIGN  w123, $F07B
          MS_ASSIGN  w124, $F07C
          MS_ASSIGN  w125, $F07D
          MS_ASSIGN  w126, $F07E
          MS_ASSIGN  w127, $F07F
          MS_ASSIGN  read_RAM, $F080
          MS_ASSIGN  rRAM, $F080
          MS_ASSIGN  r000, $F080
          MS_ASSIGN  r001, $F081
          MS_ASSIGN  r002, $F082
          MS_ASSIGN  r003, $F083
          MS_ASSIGN  r004, $F084
          MS_ASSIGN  r005, $F085
          MS_ASSIGN  r006, $F086
          MS_ASSIGN  r007, $F087
          MS_ASSIGN  r008, $F088
          MS_ASSIGN  r009, $F089
          MS_ASSIGN  r010, $F08A
          MS_ASSIGN  r011, $F08B
          MS_ASSIGN  r012, $F08C
          MS_ASSIGN  r013, $F08D
          MS_ASSIGN  r014, $F08E
          MS_ASSIGN  r015, $F08F
          MS_ASSIGN  r016, $F090
          MS_ASSIGN  r017, $F091
          MS_ASSIGN  r018, $F092
          MS_ASSIGN  r019, $F093
          MS_ASSIGN  r020, $F094
          MS_ASSIGN  r021, $F095
          MS_ASSIGN  r022, $F096
          MS_ASSIGN  r023, $F097
          MS_ASSIGN  r024, $F098
          MS_ASSIGN  r025, $F099
          MS_ASSIGN  r026, $F09A
          MS_ASSIGN  r027, $F09B
          MS_ASSIGN  r028, $F09C
          MS_ASSIGN  r029, $F09D
          MS_ASSIGN  r030, $F09E
          MS_ASSIGN  r031, $F09F
          MS_ASSIGN  r032, $F0A0
          MS_ASSIGN  r033, $F0A1
          MS_ASSIGN  r034, $F0A2
          MS_ASSIGN  r035, $F0A3
          MS_ASSIGN  r036, $F0A4
          MS_ASSIGN  r037, $F0A5
          MS_ASSIGN  r038, $F0A6
          MS_ASSIGN  r039, $F0A7
          MS_ASSIGN  r040, $F0A8
          MS_ASSIGN  r041, $F0A9
          MS_ASSIGN  r042, $F0AA
          MS_ASSIGN  r043, $F0AB
          MS_ASSIGN  r044, $F0AC
          MS_ASSIGN  r045, $F0AD
          MS_ASSIGN  r046, $F0AE
          MS_ASSIGN  r047, $F0AF
          MS_ASSIGN  r048, $F0B0
          MS_ASSIGN  r049, $F0B1
          MS_ASSIGN  r050, $F0B2
          MS_ASSIGN  r051, $F0B3
          MS_ASSIGN  r052, $F0B4
          MS_ASSIGN  r053, $F0B5
          MS_ASSIGN  r054, $F0B6
          MS_ASSIGN  r055, $F0B7
          MS_ASSIGN  r056, $F0B8
          MS_ASSIGN  r057, $F0B9
          MS_ASSIGN  r058, $F0BA
          MS_ASSIGN  r059, $F0BB
          MS_ASSIGN  r060, $F0BC
          MS_ASSIGN  r061, $F0BD
          MS_ASSIGN  r062, $F0BE
          MS_ASSIGN  r063, $F0BF
          MS_ASSIGN  r064, $F0C0
          MS_ASSIGN  r065, $F0C1
          MS_ASSIGN  r066, $F0C2
          MS_ASSIGN  r067, $F0C3
          MS_ASSIGN  r068, $F0C4
          MS_ASSIGN  r069, $F0C5
          MS_ASSIGN  r070, $F0C6
          MS_ASSIGN  r071, $F0C7
          MS_ASSIGN  r072, $F0C8
          MS_ASSIGN  r073, $F0C9
          MS_ASSIGN  r074, $F0CA
          MS_ASSIGN  r075, $F0CB
          MS_ASSIGN  r076, $F0CC
          MS_ASSIGN  r077, $F0CD
          MS_ASSIGN  r078, $F0CE
          MS_ASSIGN  r079, $F0CF
          MS_ASSIGN  r080, $F0D0
          MS_ASSIGN  r081, $F0D1
          MS_ASSIGN  r082, $F0D2
          MS_ASSIGN  r083, $F0D3
          MS_ASSIGN  r084, $F0D4
          MS_ASSIGN  r085, $F0D5
          MS_ASSIGN  r086, $F0D6
          MS_ASSIGN  r087, $F0D7
          MS_ASSIGN  r088, $F0D8
          MS_ASSIGN  r089, $F0D9
          MS_ASSIGN  r090, $F0DA
          MS_ASSIGN  r091, $F0DB
          MS_ASSIGN  r092, $F0DC
          MS_ASSIGN  r093, $F0DD
          MS_ASSIGN  r094, $F0DE
          MS_ASSIGN  r095, $F0DF
          MS_ASSIGN  r096, $F0E0
          MS_ASSIGN  r097, $F0E1
          MS_ASSIGN  r098, $F0E2
          MS_ASSIGN  r099, $F0E3
          MS_ASSIGN  r100, $F0E4
          MS_ASSIGN  r101, $F0E5
          MS_ASSIGN  r102, $F0E6
          MS_ASSIGN  r103, $F0E7
          MS_ASSIGN  r104, $F0E8
          MS_ASSIGN  r105, $F0E9
          MS_ASSIGN  r106, $F0EA
          MS_ASSIGN  r107, $F0EB
          MS_ASSIGN  r108, $F0EC
          MS_ASSIGN  r109, $F0ED
          MS_ASSIGN  r110, $F0EE
          MS_ASSIGN  r111, $F0EF
          MS_ASSIGN  r112, $F0F0
          MS_ASSIGN  r113, $F0F1
          MS_ASSIGN  r114, $F0F2
          MS_ASSIGN  r115, $F0F3
          MS_ASSIGN  r116, $F0F4
          MS_ASSIGN  r117, $F0F5
          MS_ASSIGN  r118, $F0F6
          MS_ASSIGN  r119, $F0F7
          MS_ASSIGN  r120, $F0F8
          MS_ASSIGN  r121, $F0F9
          MS_ASSIGN  r122, $F0FA
          MS_ASSIGN  r123, $F0FB
          MS_ASSIGN  r124, $F0FC
          MS_ASSIGN  r125, $F0FD
          MS_ASSIGN  r126, $F0FE
          MS_ASSIGN  r127, $F0FF
          MS_ASSIGN  switchbw, $0282
          MS_ASSIGN  screenheight, 192
          MS_ASSIGN  rand16, $00F2

; Stubs moved here to avoid adding bytes before data section at $F100
; NOTE: pfread doesn’t need rts - it’s only used as an address, not called with jsr
pfread
