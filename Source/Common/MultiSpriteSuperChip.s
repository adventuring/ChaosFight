;; ChaosFight superchip RAM definitions and ChaosFight-specific additions.
;; The upstream multisprite definitions are included separately.
;; NOTE: processor 6502 directive is in AssemblyConfig.bas, not here
;;; Default TV mode (overridden by platform files)
;;; TVStandard is defined by platform files (NTSC.s, PAL.s, SECAM.s)
;;; Forward references are fine - 64tass will resolve them automatically


;; CRITICAL: Define memory address variables FIRST to allow DASM to resolve forward references
;; These must be defined before any code that uses them
.weak
.weak
missile1height = $A4
missile0height = $A5
;; playfieldRow is defined via dim in Variables.s
;; rand16 is in SCRAM (w120/r120) to avoid stack area ($f0-$ff)
;; CRITICAL: $f0-$ff is 100% reserved for stack - NO variables allowed
;; rand16 is defined in Variables.s as rand16_W and rand16_R
;; All code must use rand16_W for writes and rand16_R for reads - no aliases allowed

;; .include "vcs.h" (commented out - DASM header, not needed for 64tass)
;; .include "macro.h" (commented out - DASM header, not needed for 64tass)
;; Issue #930: Ensure every SuperChip SCRAM port symbol is exported here so
;; cross-bank routines rely on one authoritative header.
;; CRITICAL: Define standard batariBASIC and multisprite symbols BEFORE redefs file
;; Multisprite kernel uses different addresses than standard batariBASIC (see multisprite.h)
;; Standard TIA/RIOT registers (multisprite layout from multisprite.h)
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
;; aux2 and pfcolortable moved to safe zero-page locations (see below)
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
;; Multisprite temp variables (different addresses than standard batariBASIC)
temp1 = $CB
temp2 = $CC
temp3 = $CD
temp4 = $CE
temp5 = $CF
temp6 = $D0
temp7 = $D1
score = $D2
;; Kernel variables moved from stack space ($f0-$ff) to safe zero-page locations
pfcolortable = $D3
aux2 = $D4
spritesort = $D5
spritesort2 = $D6
spritesort3 = $D7
spritesort4 = $D8
spritesort5 = $D9
scorecolor = $DA
rand = $DB
;; Multisprite letter variables (different addresses than standard batariBASIC)
;; Single-char variable aliases removed - use actual memory addresses directly
;; Memory addresses: $dc-$ef (20 bytes for a-z variables)
;; Note: qtcontroller uses $e7 (same as L/l would have used)
qtcontroller = $e7
;; CRITICAL: $f0-$ff is 100% reserved for stack - NO variables allowed
;; Z/z removed - use SCRAM for any variables that were using z
;; stack1-4 are stack addresses ($f6-$f9) - defined as constants for kernel code
;; but they are NOT variables - they are stack space that kernel may use directly
stack1 = $f6
stack2 = $f7
stack3 = $f8
stack4 = $f9
          ;; Compile-time constants (from MS_ASSIGN macros, but defined unconditionally here)
          player9height = $BC
          pfscore = 1
          pfrowheight = 16
          screenheight = 192
          ;; Additional compile-time constants for kernel and system
          noscore = 0
          mk_score_on = 1
          NO_ILLEGAL_OPCODES = 0
          minikernel = 0
          ECHOFIRST = 0
          switchbw = $0282
          ;; Note: NOT is a batariBASIC keyword (bitwise NOT operator), not a constant
          ;; Compile-time constants (playfield dimensions)
          pfrows = 8
;; Note: Multisprite kernel uses different memory layout than standard batariBASIC
;; The definitions above match multisprite.h, which is the authoritative source
;; --- Multisprite compatibility macros ----------------------------------------
;; Preserve the RETURN macro expected by multisprite-generated assembly.
.endweak
;; This must be defined early so it is available to all included files.
.endweak
          RETURN .macro
          .if !bankswitch
          rts
          .else
          jmp BS_return
          .fi
          .endmacro

;; CRITICAL: Define base variables (var0-var48) BEFORE redefs file so symbols can resolve
;; These MUST be defined unconditionally (not ifnconst) and appear before the redefs include
;; Note: Multisprite doesn’t use var0-var48 in the same way as standard batariBASIC,
;; but we define them here for compatibility with code that might reference them
;; Base variable definitions (var0-var48) - define unconditionally to ensure they exist
;; var0 = $A4 (commented - defined in Variables.s)
;; var1 = $A5 (commented - defined in Variables.s)
;; var2 = $A6 (commented - defined in Variables.s)
;; var3 = $A7 (commented - defined in Variables.s)
;; var4 = $A8 (commented - defined in Variables.s)
;; var5 = $A9 (commented - defined in Variables.s)
;; var6 = $AA (commented - defined in Variables.s)
;; var7 = $AB (commented - defined in Variables.s)
;; var8 = $AC (commented - defined in Variables.s)
;; var9 = $AD (commented - defined in Variables.s)
;; var10 = $AE (commented - defined in Variables.s)
;; var11 = $AF (commented - defined in Variables.s)
;; var12 = $B0 (commented - defined in Variables.s)
;; var13 = $B1 (commented - defined in Variables.s)
;; var14 = $B2 (commented - defined in Variables.s)
;; var15 = $B3 (commented - defined in Variables.s)
;; var16 = $B4 (commented - defined in Variables.s)
;; var17 = $B5 (commented - defined in Variables.s)
;; var18 = $B6 (commented - defined in Variables.s)
;; var19 = $B7 (commented - defined in Variables.s)
;; var20 = $B8 (commented - defined in Variables.s)
;; var21 = $B9 (commented - defined in Variables.s)
;; var22 = $BA (commented - defined in Variables.s)
;; var23 = $BB (commented - defined in Variables.s)
;; var24 = $BC (commented - defined in Variables.s)
;; var25 = $BD (commented - defined in Variables.s)
;; Variable aliases removed - use actual memory addresses directly
;; Memory layout:
;; - var0-var47: $A4-$D3 (zero-page RAM)
;; - SuperChip RAM write ports: $F000-$F07F (w000-w127)
;; - SuperChip RAM read ports: $F080-$F0FF (r000-r127)
;; Note: var48-var127 don't exist - SuperChip RAM accessed via r000-r127/w000-w127 only
;; Use DASM include (not #include) since file is generated by batariBASIC after cpp preprocessing
;; Path: 2600basic_variable_redefs.h (relative to Object/ directory where DASM runs with -I. include path)
;; Base variables (var0, n, u, etc.) and SuperChip ports (r000-r127, w000-w127) are defined above
;; before this include, so they exist when the redefs file references them
          ;; .include "2600basic_variable_redefs.h" (commented out - DASM header, not needed for 64tass)

;; Define compiler constants if not already defined by batariBASIC
;; These are forward declarations that may be redefined by batariBASIC’s generated constants
          .if !pfres
pfres = 8
          .fi
multisprite = 2
superchip = 1
bankswitch_hotspot = $ffe0
overscan_time = 36
          ;; vblank_bB_code is defined in Bank15.s where VblankHandlerTrampoline is located

;; Bank boundary definitions for 64K SuperChip ROM (16 banks x 4K each)
;; Each bank reserves space for bankswitching code at the end
;; Bankswitch code starts at $FE0 - bscode_length in each bank’s ORG space
BANKN_END = (N-1)*$1000 + $FE0 - bscode_length
;; NOTE: These definitions are generated based on Bank*CodeEnds
;; labels, so they should not be defined here to avoid overwriting the calculated values.

;; Note: ORG/RORG and repeat block removed - these cause issues when included
;; in batariBASIC asm blocks. The variable definitions below don’t require
;; these directives.
;; ORG $0000
;; RORG $F000
;; repeat 256
;; .byte $ff
;; repend

;; ChaosFight combined multisprite + superchip header.
;; Provides the 2600basic variable map alongside the multisprite kernel aliases
;; so DASM receives a single, consistent definition set.
;; Licensed under CC0 to match upstream batariBASIC headers.
;;
;; --- Helper macro -----------------------------------------------------------
;; Guarantee that every symbol is exported to the DASM symbol table while still
;; permitting reassignment when upstream headers predefine it.
;;
          ;; MS_ASSIGN macro (commented out - DASM macro, replaced with direct assignments)
          ;; MS_ASSIGN param1, param2 -> param1 = param2
;;
;; --- Multisprite workspace remapping ----------------------------------------
;; Re-apply the multisprite kernel layout while keeping symbols exported.
;;
;;           missile0x = $80
;;           missile1x = $81
;;           ballx = $82

;; multisprite bookkeeping (5 bytes per sprite set)
;; SpriteIndex = $83 (duplicate - already defined above)

;;           player0x = $84
;; X position for multiplexed sprites
;; NewSpriteX = $85 (duplicate - already defined above)
;;           player1x = $85
;;           player2x = $86
;;           player3x = $87
;;           player4x = $88
;;           player5x = $89

;;           objecty = $8A
;;           missile0y = $8A
;;           missile1y = $8B
;;           bally = $8C

;;           player0y = $8D
;; Y position for multiplexed sprites
;; NewSpriteY = $8E (duplicate - already defined above)
;;           player1y = $8E
;;           player2y = $8F
;;           player3y = $90
;;           player4y = $91
;;           player5y = $92

;; NewNUSIZ = $93 (duplicate - already defined above)
;;           _NUSIZ1 = $93
;; NUSIZ2 = $94 (duplicate - already defined above)
;; NUSIZ3 = $95 (duplicate - already defined above)
;; NUSIZ4 = $96 (duplicate - already defined above)
;; NUSIZ5 = $97 (duplicate - already defined above)

;; NewCOLUP1 = $98 (duplicate - already defined above)
;;           _COLUP1 = $98
;; COLUP2 = $99 (duplicate - already defined above)
;; COLUP3 = $9A (duplicate - already defined above)
;; COLUP4 = $9B (duplicate - already defined above)
;; COLUP5 = $9C (duplicate - already defined above)

;; SpriteGfxIndex = $9D (duplicate - already defined above)

;;           player0pointer = $A2
;;           player0pointerlo = $A2
;;           player0pointerhi = $A3

;; P0Top = temp5 in original kernel; use a hard value to avoid dasm issues.
;; P0Top = $CF (duplicate - already defined above)
;; P0Bottom = $A4 (duplicate - already defined above)
;; P1Bottom = $A5 (duplicate - already defined above)

;;           player1pointerlo = $A6
;;           player2pointerlo = $A7
;;           player3pointerlo = $A8
;;           player4pointerlo = $A9
;;           player5pointerlo = $AA

;;           player1pointerhi = $AB
;;           player2pointerhi = $AC
;;           player3pointerhi = $AD
;;           player4pointerhi = $AE
;;           player5pointerhi = $AF

;;           player0height = $B0
;; heights of multiplexed player sprite
;;           spriteheight = $B1
;;           player1height = $B1
;;           player2height = $B2
;;           player3height = $B3
;;           player4height = $B4
;;           player5height = $B5

;;           pfpixelheight = $BA

;; playfield pointers now reference sprite data
;;           playfield = $BB

;;           statusbarlength = $BF
;;           aux3 = $BF

;;           lifecolor = $C0
;;           pfscorecolor = $C0
;;           aux4 = $C0

;; P1display reused for multisprite bookkeeping (hard-coded to avoid dasm issues)
;;           lifepointer = $C1
;;           lives = $C2
;;           pfscore1 = $C1
;;           pfscore2 = $C2
;;           aux5 = $C1
;;           aux6 = $C2

;;           playfieldpos = $C3

;; RepoLine reused for multisprite bookkeeping

;;           pfheight = $C4
;;           scorepointers = $C5

;; kernel temps are relocated for multisprite
;;           temp1 = $CB
;;           temp2 = $CC
;;           temp3 = $CD
;;           temp4 = $CE
;;           temp5 = $CF
;;           temp6 = $D0
;; used to aid in bankswitching
;;           temp7 = $D1

;;           score = $D2
;; Kernel variables moved from stack space ($f0-$ff) to safe zero-page locations
;;           pfcolortable = $D3
;;           aux2 = $D4
;;           spritesort = $D5
;;           spritesort2 = $D6
;;           spritesort3 = $D7
;;           spritesort4 = $D8
;;           spritesort5 = $D9
;;           scorecolor = $DA
;;           rand = $DB

;;           A = $DC
;;           a = $DC
;;           B = $DD
;;           b = $DD
;;           C = $DE
;;           c = $DE
;;           D = $DF
;;           d = $DF
;;           E = $E0
;;           e = $E0
;;           F = $E1
;;           f = $E1
;;           G = $E2
;;           g = $E2
;;           H = $E3
;;           h = $E3
;;           I = $E4
;;           i = $E4
;;           J = $E5
;;           j = $E5
;;           K = $E6
;;           k = $E6
;;           L = $E7
;;           l = $E7
;;           M = $E8
;;           m = $E8
;;           N = $E9
;;           n = $E9
;;           O = $EA
;;           o = $EA
;;           P = $EB
;;           p = $EB
;;           Q = $EC
;;           q = $EC
;;           R = $ED
;;           r = $ED
;;           S = $EE
;;           s = $EE
;;           T = $EF
;;           t = $EF
;;           U = $EB
;;           u = $EB
;;           V = $EC
;;           v = $EC
;;           W = $ED
;;           w = $ED
;;           X = $EE
;;           x = $EE
;;           Y = $EF
;;           y = $EF
;; CRITICAL: $f0-$ff is 100% reserved for stack - NO variables allowed
;; Z/z removed - use SCRAM for any variables that were using z
;; stack1-4 are stack addresses ($f6-$f9) - defined as constants for kernel code
;; but they are NOT variables - they are stack space that kernel may use directly
;;           stack1 = $F6
;;           stack2 = $F7
;;           stack3 = $F8
;;           stack4 = $F9

;; --- Zero-page utility aliases ------------------------------------------------
          ;; NOTE: missile1height, missile0height are now defined at the top of this file
          ;; to allow DASM to resolve forward references
          ;; playfieldRow is defined via dim in Variables.s, not here
          ;; rand16 is defined in Variables.s as rand16_W and rand16_R (SCRAM)
          ballheight = $92
          currentpaddle = $90
          paddle = $91
          player0colorstore = $82
          player0color = $90
          player1color = $87
;;           player9height = $BC
          aux1 = $D3
;;           aux2 = $D4
;;           pfcolortable = $D3
          pfheighttable = $D3

;; --- Zero-page variable labels ------------------------------------------------
;; Explicit EQU definitions for var variables to ensure DASM can resolve
;; zero-page addresses. MS_ASSIGN creates constants, but DASM needs labels
;; for zero-page addressing (e.g., STA var42).
;; These EQU definitions come before MS_ASSIGN so they take precedence.
;;           var0  = $A4
;;           var1  = $A5
;;           var2  = $A6
;;           var3  = $A7
;;           var4  = $A8
;;           var5  = $A9
;;           var6  = $AA
;;           var7  = $AB
;;           var8  = $AC
;;           var9  = $AD
;;           var10 = $AE
;;           var11 = $AF
;;           var12 = $B0
;;           var13 = $B1
;;           var14 = $B2
;;           var15 = $B3
;;           var16 = $B4
;;           var17 = $B5
;;           var18 = $B6
;;           var19 = $B7
;;           var20 = $B8
;;           var21 = $B9
;;           var22 = $BA
;;           var23 = $BB
;;           var24 = $BC
          var25 = $BD
          var26 = $BE
          ;; var27-var47 aliases removed - use actual memory addresses directly
;; Letter variables (u, v, w, x, y) for zero-page addressing
;; u = $EB
;; U = $EB
;; v = $EC
;; V = $EC
;; w = $ED
;; W = $ED
;; x = $EE
;; X = $EE
;; y = $EF
;; Y = $EF
;; Stack addresses (not variables - stack space $f6-$f9)
;; stack1 = $F6
;; stack2 = $F7
;; stack3 = $F8
;; stack4 = $F9
;; var48-var127 don’t exist in multisprite - SuperChip RAM is accessed via r000-r127/w000-w127
;; Variable aliases - ensure batariBASIC variable aliases are also assembly labels
;; These are defined in Variables.s as dim aliases, but assembler needs labels
;; Use = instead of EQU so it’s a label (not just a constant) for indexed addressing
;; playerCharacter is in SCRAM (w111-w114), not zero-page, so no label needed here

;;           var0 = $A4
;;           var1 = $A5
;;           var2 = $A6
;;           var3 = $A7
;;           var4 = $A8
;;           var5 = $A9
;;           var6 = $AA
;;           var7 = $AB
;;           var8 = $AC
;;           var9 = $AD
;;           var10 = $AE
;;           var11 = $AF
;;           var12 = $B0
;;           var13 = $B1
;;           var14 = $B2
;;           var15 = $B3
;;           var16 = $B4
;;           var17 = $B5
;;           var18 = $B6
;;           var19 = $B7
;;           var20 = $B8
;;           var21 = $B9
;;           var22 = $BA
;;           var23 = $BB
;;           var24 = $BC
;;           var25 = $BD
;;           var26 = $BE
;;           var27 = $BF
;;           var28 = $C0
;;           var29 = $C1
;;           var30 = $C2
;;           var31 = $C3
;;           var32 = $C4
;;           var33 = $C5
;;           var34 = $C6
;;           var35 = $C7
;;           var36 = $C8
;;           var37 = $C9
;;           var38 = $CA
;;           var39 = $CB
;;           var40 = $CC
;;           var41 = $CD
;;           var42 = $CE
;;           var43 = $CF
;;           var44 = $D0
;;           var45 = $D1
;;           var46 = $D2
;;           var47 = $D3
;;           var48 = $D4 (commented - defined in Variables.s)
;;           pfscore = 1
;;           noscore = 0
          ROM2k = 0
          PXE = 0
          ;;           pfrowheight = 16
          ;;           pfrows = 8

  ;; Define debugcycles as a stub label (kernel defines it when debugscore enabled)
  ;; MS_ASSIGN would create a constant, but we need a label for jsr debugcycles
  ;; This prevents phase errors when debugscore is disabled but jsr debugcycles is generated
  ;; Note: debugcycles is defined above as a label, not a constant
  ;; This matches the kernel’s usage where jsr debugcycles is called

  ;; Forward declarations for batariBASIC built-in variables and routines
  ;; These will be defined by batariBASIC compiler/generated code
  ;; ECHOFIRST is defined above unconditionally
  ;; NOTE: frame is a batariBASIC built-in variable - do not define it here
  ;; Standard batariBASIC routines (defined in std_routines.asm, pf_drawing.asm, div_mul.asm)
  ;; These are labels, not constants, but we forward-declare them here for symbol resolution
  ;; Note: These are actual assembly routines, not variables
  ;; randomize, setuppointers, ConvertToBCD, BlankPlayfield, PlayfieldRead, etc.
  
  ;; Forward declarations for cross-bank function labels are not allowed nor needed.
  
          interlaced = 0
          shakescreen = 0
          ;;; vblank_time is conditionally defined based on TVStandard
          .if TVStandard == PAL
                    vblank_time = 58
          .elsif TVStandard == SECAM
                    vblank_time = 58
          .else
                    vblank_time = 43
          .fi
          scorefade = 0
          ;; NO_ILLEGAL_OPCODES = 0 (duplicate - already defined above)
          DPC_kernel_options = 0
          debugscore = 0
          legacy = 0
          readpaddle = 0
          backgroundchange = 0
          font = 0
          mincycles = 232
          pfcenter = 0
          FASTFETCH = 0
          ;;           minikernel = 0
          vertical_reflect = 1
          no_blank_lines = 0
          PFmaskvalue = 0
          ;; NOT is a batariBASIC keyword (bitwise NOT operator), not a constant - do not define
          ;; NOTE: playfieldRow is defined via dim in Variables.s, not here
          ;; FontData is defined in Source/Generated/Numbers.bas - do not define here
          ;; Forward assignments are not supported - use the actual label from Numbers.bas
          gamenumber = $00
          ;;           mk_score_on = 1
          mk_gameselect_on = 0
  ;; qtcontroller is defined above at line 978 as $E7 (multisprite uses q=$E7)
  ;; frame is a user variable that must be dimmed - not provided by kernel
  ;; For multisprite, frame should be dimmed to a standard RAM location (a-z or var0-var47)
  ;; scoretable is defined in Source/Common/ScoreTable.s (replacement for score_graphics.asm)
;; NOTE: pfread stub moved to end of file to avoid adding byte before data section

;; --- Superchip RAM mapping --------------------------------------------------
;; Mirror the standard SuperChip read/write port map so DASM exports every alias.
          write_RAM = $F000
          wRAM = $F000
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
          read_RAM = $F080
          rRAM = $F080
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
;;           switchbw = $0282
;;           screenheight = 192
          ;; rand16 is optional (used by randomize if defined)
          ;; rand16 is defined in Variables.s as rand16_W and rand16_R (SCRAM)
          ;; NOT is a batariBASIC keyword (bitwise NOT operator), not a constant
          ;; Do NOT define it here - it causes syntax errors when used as an operator
          ;; If you need a bitwise NOT mask, use ($FF ^ value) instead of (NOT value)


