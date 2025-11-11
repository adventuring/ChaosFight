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
  MS_ASSIGN  missile0x        $80
  MS_ASSIGN  missile1x        $81
  MS_ASSIGN  ballx            $82

; multisprite bookkeeping (5 bytes per sprite set)
  MS_ASSIGN  SpriteIndex      $83

  MS_ASSIGN  player0x         $84
; X position for multiplexed sprites
  MS_ASSIGN  NewSpriteX       $85
  MS_ASSIGN  player1x         $85
  MS_ASSIGN  player2x         $86
  MS_ASSIGN  player3x         $87
  MS_ASSIGN  player4x         $88
  MS_ASSIGN  player5x         $89

  MS_ASSIGN  objecty          $8A
  MS_ASSIGN  missile0y        $8A
  MS_ASSIGN  missile1y        $8B
  MS_ASSIGN  bally            $8C

  MS_ASSIGN  player0y         $8D
; Y position for multiplexed sprites
  MS_ASSIGN  NewSpriteY       $8E
  MS_ASSIGN  player1y         $8E
  MS_ASSIGN  player2y         $8F
  MS_ASSIGN  player3y         $90
  MS_ASSIGN  player4y         $91
  MS_ASSIGN  player5y         $92

  MS_ASSIGN  NewNUSIZ         $93
  MS_ASSIGN  _NUSIZ1          $93
  MS_ASSIGN  NUSIZ2           $94
  MS_ASSIGN  NUSIZ3           $95
  MS_ASSIGN  NUSIZ4           $96
  MS_ASSIGN  NUSIZ5           $97

  MS_ASSIGN  NewCOLUP1        $98
  MS_ASSIGN  _COLUP1          $98
  MS_ASSIGN  COLUP2           $99
  MS_ASSIGN  COLUP3           $9A
  MS_ASSIGN  COLUP4           $9B
  MS_ASSIGN  COLUP5           $9C

  MS_ASSIGN  SpriteGfxIndex   $9D

  MS_ASSIGN  player0pointer   $A2
  MS_ASSIGN  player0pointerlo $A2
  MS_ASSIGN  player0pointerhi $A3

; P0Top = temp5 in original kernel; use a hard value to avoid dasm issues.
  MS_ASSIGN  P0Top            $CF
  MS_ASSIGN  P0Bottom         $A4
  MS_ASSIGN  P1Bottom         $A5

  MS_ASSIGN  player1pointerlo $A6
  MS_ASSIGN  player2pointerlo $A7
  MS_ASSIGN  player3pointerlo $A8
  MS_ASSIGN  player4pointerlo $A9
  MS_ASSIGN  player5pointerlo $AA

  MS_ASSIGN  player1pointerhi $AB
  MS_ASSIGN  player2pointerhi $AC
  MS_ASSIGN  player3pointerhi $AD
  MS_ASSIGN  player4pointerhi $AE
  MS_ASSIGN  player5pointerhi $AF

  MS_ASSIGN  player0height    $B0
; heights of multiplexed player sprite
  MS_ASSIGN  spriteheight     $B1
  MS_ASSIGN  player1height    $B1
  MS_ASSIGN  player2height    $B2
  MS_ASSIGN  player3height    $B3
  MS_ASSIGN  player4height    $B4
  MS_ASSIGN  player5height    $B5

  MS_ASSIGN  PF1temp1         $B6
  MS_ASSIGN  PF1temp2         $B7
  MS_ASSIGN  PF2temp1         $B8
  MS_ASSIGN  PF2temp2         $B9

  MS_ASSIGN  pfpixelheight    $BA

; playfield pointers now reference sprite data
  MS_ASSIGN  playfield        $BB
  MS_ASSIGN  PF1pointer       $BB
  MS_ASSIGN  PF2pointer       $BD

  MS_ASSIGN  statusbarlength  $BF
  MS_ASSIGN  aux3             $BF

  MS_ASSIGN  lifecolor        $C0
  MS_ASSIGN  pfscorecolor     $C0
  MS_ASSIGN  aux4             $C0

; P1display reused for kernel bookkeeping (hard-coded to avoid dasm issues)
  MS_ASSIGN  P1display        $CC
  MS_ASSIGN  lifepointer      $C1
  MS_ASSIGN  lives            $C2
  MS_ASSIGN  pfscore1         $C1
  MS_ASSIGN  pfscore2         $C2
  MS_ASSIGN  aux5             $C1
  MS_ASSIGN  aux6             $C2

  MS_ASSIGN  playfieldpos     $C3

; RepoLine reused for multisprite bookkeeping
  MS_ASSIGN  RepoLine         $CE

  MS_ASSIGN  pfheight         $C4
  MS_ASSIGN  scorepointers    $C5

; kernel temps are relocated for multisprite
  MS_ASSIGN  temp1            $CB
  MS_ASSIGN  temp2            $CC
  MS_ASSIGN  temp3            $CD
  MS_ASSIGN  temp4            $CE
  MS_ASSIGN  temp5            $CF
  MS_ASSIGN  temp6            $D0
; used to aid in bankswitching
  MS_ASSIGN  temp7            $D1

  MS_ASSIGN  score            $D2
; relocated to preserve kernel workspace
  MS_ASSIGN  scorecolor       $D5
  MS_ASSIGN  rand             $D6

  MS_ASSIGN  A                $D7
  MS_ASSIGN  a                $D7
  MS_ASSIGN  B                $D8
  MS_ASSIGN  b                $D8
  MS_ASSIGN  C                $D9
  MS_ASSIGN  c                $D9
  MS_ASSIGN  D                $DA
  MS_ASSIGN  d                $DA
  MS_ASSIGN  E                $DB
  MS_ASSIGN  e                $DB
  MS_ASSIGN  F                $DC
  MS_ASSIGN  f                $DC
  MS_ASSIGN  G                $DD
  MS_ASSIGN  g                $DD
  MS_ASSIGN  H                $DE
  MS_ASSIGN  h                $DE
  MS_ASSIGN  I                $DF
  MS_ASSIGN  i                $DF
  MS_ASSIGN  J                $E0
  MS_ASSIGN  j                $E0
  MS_ASSIGN  K                $E1
  MS_ASSIGN  k                $E1
  MS_ASSIGN  L                $E2
  MS_ASSIGN  l                $E2
  MS_ASSIGN  M                $E3
  MS_ASSIGN  m                $E3
  MS_ASSIGN  N                $E4
  MS_ASSIGN  n                $E4
  MS_ASSIGN  O                $E5
  MS_ASSIGN  o                $E5
  MS_ASSIGN  P                $E6
  MS_ASSIGN  p                $E6
  MS_ASSIGN  Q                $E7
  MS_ASSIGN  q                $E7
  MS_ASSIGN  R                $E8
  MS_ASSIGN  r                $E8
  MS_ASSIGN  S                $E9
  MS_ASSIGN  s                $E9
  MS_ASSIGN  T                $EA
  MS_ASSIGN  t                $EA
  MS_ASSIGN  U                $EB
  MS_ASSIGN  u                $EB
  MS_ASSIGN  V                $EC
  MS_ASSIGN  v                $EC
  MS_ASSIGN  W                $ED
  MS_ASSIGN  w                $ED
  MS_ASSIGN  X                $EE
  MS_ASSIGN  x                $EE
  MS_ASSIGN  Y                $EF
  MS_ASSIGN  y                $EF
  MS_ASSIGN  Z                $F0
  MS_ASSIGN  z                $F0

  MS_ASSIGN  spritesort       $F1
  MS_ASSIGN  spritesort2      $F2
  MS_ASSIGN  spritesort3      $F3
  MS_ASSIGN  spritesort4      $F4
  MS_ASSIGN  spritesort5      $F5

  MS_ASSIGN  stack1           $F6
  MS_ASSIGN  stack2           $F7
  MS_ASSIGN  stack3           $F8
  MS_ASSIGN  stack4           $F9

