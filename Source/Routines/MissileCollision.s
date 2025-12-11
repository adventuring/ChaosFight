;;; ChaosFight - Source/Routines/MissileCollision.bas

;;; Copyright © 2025 Bruce-Robert Pocock.



CheckAllMissileCollisions:
          ;; Returns: Far (return otherbank)

          ;; Missile Collision System
          ;; Returns: Far (return otherbank)

          ;; Handles all collision detection for missiles and

          ;; area-of-effect attacks.

          ;; COLLISION TYPES:

          ;; 1. Missile-to-Player: Visible missiles (ranged or mêlée

          ;; visuals)

          ;; 2. AOE-to-Player: Mêlée attacks with no visible missile

          ;; (0×0 size)

          ;; 3. Missile-to-Playfield: For missiles that interact with

          ;; walls

          ;; SPECIAL CASES:

          ;; - Bernie: AOE extends both left and right simultaneously

          ;; - Other mêlée: AOE only in facing direction

          ;;
          ;; FACING DIRECTION FORMULA (for AOE attacks):

          ;; Facing right (bit 0 = 1): AOE_X = playerX + offset

          ;; Facing left  (bit 0 = 0): AOE_X = playerX + 7 - offset

          ;; Check all missile collisions (visible missiles and AOE) each frame.

          ;; Input: temp1 = attacker player index (0-3)

          ;; missileActive (global) = missile active flags

          ;; playerCharacter[] (global) = character types

          ;; Output: temp4 = hit player index (0-3) if hit, MissileHitNotFound otherwise

          ;; Mutates: temp1-temp6, temp4

          ;;
          ;; Called Routines: CheckVisibleMissileCollision (tail call) - if visible

          ;; missile, CheckAOECollision (goto) - if AOE attack,

          ;; CheckPlayersAgainstCachedHitbox - shared defender scan

          ;; Constraints: None

          ;; Optimized: Calculate missile active bit flag with formula

          ;; bit flag: BitMask[playerIndex] (1, 2, 4, 8 for players 0-3)

          lda # MissileHitNotFound
          sta temp4

          ;; Set temp6 = BitMask[temp1]
          lda temp1
          asl
          tax
          lda BitMask,x
          sta temp6

          lda missileActive
          and temp6
          sta temp5

          ;; No active missile

          jmp BS_return



          ;; Cache character index for downstream routines

          ;; Set characterIndex = playerCharacter[temp1]
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta characterIndex



          ;; Visible missile when width > 0, otherwise treat as AOE

          ;; Set temp6 = CharacterMissileWidths[characterIndex]
          lda characterIndex
          asl
          tax
          lda CharacterMissileWidths,x
          sta temp6
          lda characterIndex
          asl
          tax
          lda CharacterMissileWidths,x
          sta temp6

          lda temp6
          cmp # 0
          bne CheckVisibleMissileCollision
          jmp CheckAOECollision


          ;; tail call

          jmp CheckVisibleMissileCollision





CheckVisibleMissileCollision
          ;; Returns: Near (return thisbank) - called same-bank




          ;;
          ;; Returns: Far (return otherbank)

          ;; Check Visible Missile Collision

          ;; Checks collision between a visible missile and all

          ;; players.

          ;; Uses axis-aligned bounding box (AABB) collision detection.

          ;;
          ;; INPUT:

          ;; temp1 = attacker player index (0-3, missile owner)

          ;;
          OUTPUT:

          ;; temp4 = hit player index (0-3), or 255 if no hit

          ;; Checks collision between a visible missile and all players

          ;; using AABB collision detection

          ;;
          ;; Input: temp1 = attacker player index (0-3, missile owner),

          ;; missileX[] (global array) = missile X positions,

          ;; missileY_R[] (global SCRAM array) = missile Y positions,

          ;; playerCharacter[] (global array) = character types, playerX[],

          ;; playerY[] (global arrays) = player positions,

          ;; playerHealth[] (global array) = player health

          ;;
          ;; Output: temp4 = hit player index (0-3) if hit, 255 if no

          ;; hit

          ;;
          ;; Mutates: temp1-temp6 (used for calculations), temp4

          ;; (return value)

          ;;
          ;; Called Routines: CheckPlayersAgainstCachedHitbox - scans defenders

          ;; Constraints: None

          ;; Ensure character index matches current attacker

                    ;; Set characterIndex = playerCharacter[temp1]
          ;; Set characterIndex = playerCharacter[temp1]
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta characterIndex



          ;; Set cachedHitboxLeft_W = missileX[temp1]
          lda temp1
          asl
          tax
          lda missileX,x
          sta cachedHitboxLeft_W

          ;; Set cachedHitboxTop_W = missileY_R[temp1]
          lda temp1
          asl
          tax
          lda missileY_R,x
          sta cachedHitboxTop_W



          ;; Derive hitbox bounds from missile dimensions

          ;; Set temp6 = CharacterMissileWidths[characterIndex]
          lda characterIndex
          asl
          tax
          lda CharacterMissileWidths,x
          sta temp6
          lda characterIndex
          asl
          tax
          lda CharacterMissileWidths,x
          sta temp6

          ;; Set cachedHitboxRight_W = cachedHitboxLeft_R + temp6
          ;; Set temp6 = CharacterMissileHeights[characterIndex]
          lda characterIndex
          asl
          tax
          lda CharacterMissileHeights,x
          sta temp6

          ;; Set cachedHitboxBottom_W = cachedHitboxTop_R + temp6
          jsr CheckPlayersAgainstCachedHitbox

          jmp BS_return



CheckAOECollision
          ;; Returns: Near (return thisbank) - called same-bank




          ;;
          ;; Returns: Far (return otherbank)

          ;; Check Aoe Collision

          ;; Checks collision for area-of-effect mêlée attacks (no

          ;; visible missile).

          ;; AOE is relative to player position and facing direction.

          ;; SPECIAL CASE: Bernie (character 0) Ground Thump attack

          ;; hits both left and right simultaneously, shoving enemies

          ;; away rapidly.

          ;;
          ;; INPUT:

          ;; temp1 = attacker player index (0-3)

          ;;
          ;; OUTPUT:

          ;; temp4 = hit player index (0-3), or 255 if no hit

          ;; Checks collision for area-of-effect mêlée attacks (no

          ;; visible missile)

          ;;
          ;; Input: temp1 = attacker player index (0-3), playerCharacter[]

          ;; (global array) = character types, playerState[] (global

          ;; array) = player states (bit 0 = facing), playerX[],

          ;; playerY[] (global arrays) = player positions,

          ;; playerHealth[] (global array) = player health,

          ;; CharacterAOEOffsets[] (global data table) = AOE offsets

          ;;
          ;; Output: temp4 = hit player index (0-3) if hit, 255 if no

          ;; hit

          ;;
          ;; Mutates: temp1-temp6 (used for calculations), temp4

          ;; (return value)

          ;;
          ;; Called Routines: CheckAOEDirection.Right - checks AOE

          ;; collision facing right, CheckAOEDirection.Left - checks

          ;; AOE collision facing left, CheckBernieAOE - special case

          ;; for Bernie (hits both directions)

          ;; Constraints: Bernie (character 0) hits both left and right simultaneously

          ;; Set characterIndex = playerCharacter[temp1]
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta characterIndex

          ;; Get attacker character type

          lda characterIndex
          sta temp5



          ;; Check if this is Bernie (character 0)

          ;; Bernie attacks both left and right, so check both

          ;; directions

          lda temp5
          cmp CharacterBernie
          bne CheckFacingDirection
          jmp CheckBernieAOE
CheckFacingDirection:




          ;; Normal character: Check only facing direction

          ;; Set temp6 = playerState[temp1] & PlayerStateBitFacing
          lda temp1
          asl
          tax
          lda playerState,x
          sta temp6

          lda temp6
          cmp # 0
          ;; jmp CheckAOEDirection.Left


          ;; jmp CheckAOEDirection.Right




CheckBernieAOE .proc


          ;; Bernie swings both directions every frame
          ;; Returns: Far (return otherbank)

          jsr CacheAOERightHitbox

          jsr CheckPlayersAgainstCachedHitbox

          jmp BS_return



          jsr CacheAOELeftHitbox

          jsr CheckPlayersAgainstCachedHitbox

          jmp BS_return


.pend

CheckAOEDirection .proc
          ;; Returns: Near (return thisbank) - called same-bank


          ;; Returns: Near (return thisbank) - called same-bank




          ;;
          ;; Returns: Near (return thisbank) - called same-bank

          ;; Check Aoe Direction - Right

          ;; Checks AOE collision when attacking to the right.

          ;; Formula: AOE_X = playerX + offset

          ;;
          INPUT:

          ;; temp1 = attacker player index (0-3)

          ;;
          OUTPUT:

          ;; temp4 = hit player index (0-3), or 255 if no hit

          ;; Checks AOE collision when attacking to the right (AOE_X =

          ;; playerX + offset)

          ;;
          ;; Input: temp1 = attacker player index (0-3), playerX[],

          ;; playerY[] (global arrays) = player positions, playerCharacter[]

          ;; (global array) = character types, playerHealth[] (global

          ;; array) = player health, CharacterAOEOffsets[] (global data

          ;; table) = AOE offsets

          ;;
          ;; Output: temp4 = hit player index (0-3) if hit, 255 if no

          ;; hit

          ;;
          ;; Mutates: temp1-temp6 (used for calculations), temp4

          ;; (return value)

          ;;
          ;; Called Routines: None

          ;; Constraints: None

Right:

          jsr CacheAOERightHitbox

          jsr CheckPlayersAgainstCachedHitbox

          jmp BS_return

Left:

          ;; Returns: Near (return thisbank) - called same-bank




          ;;
          ;; Returns: Near (return thisbank) - called same-bank

          ;; Check Aoe Direction - Left

          ;; Checks AOE collision when attacking to the left.

          ;; Formula: AOE_X = playerX + 7 - offset

          ;;
          ;; INPUT:

          ;; temp1 = attacker player index (0-3)

          ;;
          ;; OUTPUT:

          ;; temp4 = hit player index (0-3), or 255 if no hit

          ;; Checks AOE collision when attacking to the left (AOE_X =

          ;; playerX + 7 - offset)

          ;;
          ;; Input: temp1 = attacker player index (0-3), playerX[],

          ;; playerY[] (global arrays) = player positions, playerCharacter[]

          ;; (global array) = character types, playerHealth[] (global

          ;; array) = player health, CharacterAOEOffsets[] (global data

          ;; table) = AOE offsets

          ;;
          ;; Output: temp4 = hit player index (0-3) if hit, 255 if no

          ;; hit

          ;;
          ;; Mutates: temp1-temp6 (used for calculations), temp4

          ;; (return value)

          ;;
          ;; Called Routines: None

          ;; Constraints: None

          jsr CacheAOELeftHitbox

          jsr CheckPlayersAgainstCachedHitbox

          jmp BS_return



.pend

CacheAOERightHitbox .proc

          ;; Cache right-facing AOE bounds for current attacker
          ;; Returns: Near (return thisbank) - called same-bank

          ;; Input: temp1 = attacker index, characterIndex = character ID

          ;; Output: cachedHitboxLeft/Right/Top/Bottom populated

                    ;; Set aoeOffset = CharacterAOEOffsets[characterIndex]
          lda characterIndex
          asl
          tax
          lda CharacterAOEOffsets,x
          sta aoeOffset

          ;; Set cachedHitboxLeft_W = playerX[temp1]
          lda temp1
          asl
          tax
          lda playerX,x
          clc
          adc aoeOffset
          sta cachedHitboxLeft_W

          ;; Set cachedHitboxRight_W = cachedHitboxLeft_R + PlayerSpriteHalfWidth
          ;; Set cachedHitboxTop_W = playerY[temp1]
          lda temp1
          asl
          tax
          lda playerY,x
          sta cachedHitboxTop_W

          ;; Set cachedHitboxBottom_W = cachedHitboxTop_R + PlayerSpriteHeight
          rts



.pend

CacheAOELeftHitbox .proc

          ;; Cache left-facing AOE bounds for current attacker
          ;; Returns: Near (return thisbank) - called same-bank

          ;; Input: temp1 = attacker index, characterIndex = character ID

          ;; Output: cachedHitboxLeft/Right/Top/Bottom populated

                    ;; Set aoeOffset = CharacterAOEOffsets[characterIndex]
          lda characterIndex
          asl
          tax
          lda CharacterAOEOffsets,x
          sta aoeOffset

          ;; Set cachedHitboxRight_W = playerX[temp1] + PlayerSpriteWidth - 1 - aoeOffset
          lda temp1
          asl
          tax
          lda playerX,x
          sta cachedHitboxRight_W

          ;; Set cachedHitboxLeft_W = cachedHitboxRight_R - PlayerSpriteHalfWidth
          lda cachedHitboxRight_R
          sec
          sbc # PlayerSpriteHalfWidth
          sta cachedHitboxLeft_W

          ;; Set cachedHitboxTop_W = playerY[temp1]
          lda temp1
          asl
          tax
          lda playerY,x
          sta cachedHitboxTop_W

          ;; Set cachedHitboxBottom_W = cachedHitboxTop_R + PlayerSpriteHeight
          rts

.pend

CheckPlayersAgainstCachedHitbox .proc


          ;; Shared defender scan for missile/AOE collisions
          ;; Returns: Near (return thisbank) - called same-bank

          ;; Input: temp1 = attacker index, cachedHitbox* = attacker bounds

          ;; Output: temp4 = hit player index or MissileHitNotFound
          lda MissileHitNotFound
          sta temp4

          ;; TODO: #1254 for temp2 = 0 to 3

          lda temp2
          cmp temp1
          bne CheckPlayerHealth
          jmp CPB_NextPlayerBottom
CheckPlayerHealth:


          ;; If playerHealth[temp2] = 0, then CPB_NextPlayer
          ;; If playerX[temp2] + PlayerSpriteWidth <= cachedHitboxLeft_R, then CPB_NextPlayer
          lda temp2
          asl
          tax
          lda playerX,x
          clc
          adc PlayerSpriteWidth
          sta temp6
          lda temp6
          sec
          sbc cachedHitboxLeft_R
          bcc CPB_NextPlayerLeft
          beq CPB_NextPlayerLeft
          jmp CheckRightEdge
CPB_NextPlayerLeft:
CheckRightEdge:

          ;; If playerX[temp2] >= cachedHitboxRight_R, then CPB_NextPlayer
          lda temp2
          asl
          tax
          lda playerX,x
          sec
          sbc cachedHitboxRight_R
          bcc CheckVerticalOverlap
          jmp CPB_NextPlayerBottom
CheckVerticalOverlap:

          ;; If playerY[temp2] + PlayerSpriteHeight <= cachedHitboxTop_R, then CPB_NextPlayer
          lda temp2
          asl
          tax
          lda playerY,x
          clc
          adc PlayerSpriteHeight
          sta temp6
          lda temp6
          sec
          sbc cachedHitboxTop_R
          bcc CPB_NextPlayerTop
          beq CPB_NextPlayerTop
          jmp CheckBottomEdge
CPB_NextPlayerTop:
CheckBottomEdge:

          ;; If playerY[temp2] >= cachedHitboxBottom_R, then CPB_NextPlayer
          lda temp2
          asl
          tax
          lda playerY,x
          sec
          sbc cachedHitboxBottom_R
          bcc HitDetected
          jmp CPB_NextPlayerBottom
HitDetected:
          lda temp2
          sta temp4

          rts

.pend

CPB_NextPlayerBottom:
          rts

CheckPlayersAgainstCachedHitboxDone .proc

          jmp BS_return

.pend

;; MissileCollPF .proc (no matching .pend)


          ;;
          ;; Returns: Far (return otherbank)

          ;; Check Missile-playfield Collision

          ;; Checks if missile hit the playfield (walls, obstacles).

          ;; Uses pfread to check playfield pixel at missile position.

          ;;
          ;; INPUT:

          ;; temp1 = player index (0-3)

          ;;
          ;; OUTPUT:

          ;; temp4 = 1 if hit playfield, 0 if clear

          ;; Checks if missile hit the playfield (walls, obsta


          ;; using pfread

          ;;
          ;; Input: temp1 = player index (0-3), missileX[] (global

          ;; array) = missile X positions, missileY_R[] (global SCRAM

          ;; array) = missile Y positions

          ;;
          ;; Output: temp4 = 1 if hit playfield, 0 if clear

          ;;
          ;; Mutates: temp2 (used for missile X), temp3 (used for

          ;; missile Y), temp4 (return value), temp6 (used for

          ;; playfield column calculation)

          ;;
          ;; Called Routines: None

          ;;
          ;; Constraints: None

          ;; Get missile X/Y position

                    ;; Set temp2 = missileX[temp1]
                    lda temp1
                    asl
                    tax
                    lda missileX,x
                    sta temp2

          ;; Set temp3 = missileY_R[temp1]
          lda temp1
          asl
          tax
          lda missileY_R,x
          sta temp3
          lda temp1
          asl
          tax
          lda missileY_R,x
          sta temp3



          ;; Convert × to playfield coordinates

          ;; Playfield is 32 pf-pixels wide (4px wide each, so 128 screen pixels)



          ;; Convert × pixel to playfield column

          ;; Set temp6 = temp2 - 16          lda temp2          sec          sbc 16          sta temp6
          lda temp2
          sec
          sbc 16
          sta temp6

          lda temp2
          sec
          sbc 16
          sta temp6


          ;; Set temp6 = temp6 / 4          lda temp6          lsr          lsr          sta temp6
          lda temp6
          lsr
          lsr
          sta temp6

          lda temp6
          lsr
          lsr
          sta temp6




          ;; Check if playfield pixel is set at missile position

          ;; Assume clear until pfread says otherwise

          lda # 0
          sta temp4

          lda temp6
          sta temp1

          lda temp3
          sta temp2

          ;; Cross-bank call to PlayfieldRead in bank 16
          lda # >(MissileCollisionPlayfieldReadReturn-1)
          pha
          lda # <(MissileCollisionPlayfieldReadReturn-1)
          pha
          lda # >(PlayfieldRead-1)
          pha
          lda # <(PlayfieldRead-1)
          pha
                    ldx # 15
          jmp BS_jsr
MissileCollisionPlayfieldReadReturn:


          ;; pfread(column, row) returns 0 if clear, non-zero if set

          jmp BS_return

          ;; Clear

          jmp BS_return




