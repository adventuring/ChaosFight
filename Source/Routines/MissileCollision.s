;;; ChaosFight - Source/Routines/MissileCollision.bas

;;; Copyright © 2025 Bruce-Robert Pocock.



CheckAllMissileCollisions
          ;; Returns: Far (return otherbank)


;; CheckAllMissileCollisions (duplicate)


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

          lda MissileHitNotFound
          sta temp4

                    ;; let temp6 = BitMask[temp1]          lda temp1          asl          tax          lda BitMask,x          sta temp6

          ;; lda missileActive (duplicate)
          and temp6
          ;; sta temp5 (duplicate)

          ;; No active missile

          jsr BS_return



          ;; Cache character index for downstream routines

          ;; let characterIndex = playerCharacter[temp1]
          ;; lda temp1 (duplicate)
          asl
          tax
          ;; lda playerCharacter,x (duplicate)
          ;; sta characterIndex (duplicate)



          ;; Visible missile when width > 0, otherwise treat as AOE

                    ;; let temp6 = CharacterMissileWidths[characterIndex]
          ;; lda characterIndex (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMissileWidths,x (duplicate)
          ;; sta temp6 (duplicate)
          ;; lda characterIndex (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMissileWidths,x (duplicate)
          ;; sta temp6 (duplicate)

          ;; lda temp6 (duplicate)
          cmp # 0
          bne skip_4483
          jmp CheckAOECollision
skip_4483:


          ;; tail call

          ;; jmp CheckVisibleMissileCollision (duplicate)





CheckVisibleMissileCollision
          ;; Returns: Near (return thisbank) - called same-bank


;; CheckVisibleMissileCollision (duplicate)


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
          ;; OUTPUT:

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

                    ;; let characterIndex = playerCharacter[temp1]          lda temp1          asl          tax          lda playerCharacter,x          sta characterIndex



          ;; let cachedHitboxLeft_W = missileX[temp1]
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda missileX,x (duplicate)
          ;; sta cachedHitboxLeft_W (duplicate)

          ;; let cachedHitboxTop_W = missileY_R[temp1]
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda missileY_R,x (duplicate)
          ;; sta cachedHitboxTop_W (duplicate)



          ;; Derive hitbox bounds from missile dimensions

                    ;; let temp6 = CharacterMissileWidths[characterIndex]
          ;; lda characterIndex (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMissileWidths,x (duplicate)
          ;; sta temp6 (duplicate)
          ;; lda characterIndex (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMissileWidths,x (duplicate)
          ;; sta temp6 (duplicate)

                    ;; let cachedHitboxRight_W = cachedHitboxLeft_R + temp6

                    ;; let temp6 = CharacterMissileHeights[characterIndex]         
          ;; lda characterIndex (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMissileHeights,x (duplicate)
          ;; sta temp6 (duplicate)

                    ;; let cachedHitboxBottom_W = cachedHitboxTop_R + temp6
          ;; jsr CheckPlayersAgainstCachedHitbox (duplicate)

          ;; jsr BS_return (duplicate)



CheckAOECollision
          ;; Returns: Near (return thisbank) - called same-bank


;; CheckAOECollision (duplicate)


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
          ;; Called Routines: CheckAOEDirection_Right - checks AOE

          ;; collision facing right, CheckAOEDirection_Left - checks

          ;; AOE collision facing left, CheckBernieAOE - special case

          ;; for Bernie (hits both directions)

          ;; Constraints: Bernie (character 0) hits both left and right simultaneously

                    ;; let characterIndex = playerCharacter[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta characterIndex (duplicate)

          ;; Get attacker character type

          ;; lda characterIndex (duplicate)
          ;; sta temp5 (duplicate)



          ;; Check if this is Bernie (character 0)

          ;; Bernie attacks both left and right, so check both

          ;; directions

          ;; lda temp5 (duplicate)
          ;; cmp CharacterBernie (duplicate)
          ;; bne skip_1021 (duplicate)
          ;; TODO: CheckBernieAOE
skip_1021:




          ;; Normal character: Check only facing direction

                    ;; let temp6 = playerState[temp1] & PlayerStateBitFacing         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerState,x (duplicate)
          ;; sta temp6 (duplicate)

          ;; lda temp6 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_3727 (duplicate)
          ;; jmp CheckAOEDirection_Left (duplicate)
skip_3727:


          ;; jmp CheckAOEDirection_Right (duplicate)




CheckBernieAOE .proc


          ;; Bernie swings both directions every frame
          ;; Returns: Far (return otherbank)

          ;; jsr CacheAOERightHitbox (duplicate)

          ;; jsr CheckPlayersAgainstCachedHitbox (duplicate)

          ;; jsr BS_return (duplicate)



          ;; jsr CacheAOELeftHitbox (duplicate)

          ;; jsr CheckPlayersAgainstCachedHitbox (duplicate)

          ;; jsr BS_return (duplicate)



CheckAOEDirection_Right
          ;; Returns: Near (return thisbank) - called same-bank


;; CheckAOEDirection_Right (duplicate)


          ;;
          ;; Returns: Near (return thisbank) - called same-bank

          ;; Check Aoe Direction - Right

          ;; Checks AOE collision when attacking to the right.

          ;; Formula: AOE_X = playerX + offset

          ;;
          ;; INPUT:

          ;; temp1 = attacker player index (0-3)

          ;;
          ;; OUTPUT:

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

          ;; jsr CacheAOERightHitbox (duplicate)

          ;; jsr CheckPlayersAgainstCachedHitbox (duplicate)

          ;; jsr BS_return (duplicate)



CheckAOEDirection_Left
          ;; Returns: Near (return thisbank) - called same-bank


;; CheckAOEDirection_Left (duplicate)


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

          ;; jsr CacheAOELeftHitbox (duplicate)

          ;; jsr CheckPlayersAgainstCachedHitbox (duplicate)

          ;; jsr BS_return (duplicate)



.pend

CacheAOERightHitbox .proc

          ;; Cache right-facing AOE bounds for current attacker
          ;; Returns: Near (return thisbank) - called same-bank

          ;; Input: temp1 = attacker index, characterIndex = character ID

          ;; Output: cachedHitboxLeft/Right/Top/Bottom populated

                    ;; let aoeOffset = CharacterAOEOffsets[characterIndex]          lda characterIndex          asl          tax          lda CharacterAOEOffsets,x          sta aoeOffset

                    ;; let cachedHitboxLeft_W = playerX[temp1]
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerX,x (duplicate)
          ;; sta cachedHitboxLeft_W + aoeOffset (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerX,x (duplicate)
          ;; sta cachedHitboxLeft_W (duplicate)

                    ;; let cachedHitboxRight_W = cachedHitboxLeft_R + PlayerSpriteHalfWidth

                    ;; let cachedHitboxTop_W = playerY[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; sta cachedHitboxTop_W (duplicate)

                    ;; let cachedHitboxBottom_W = cachedHitboxTop_R + PlayerSpriteHeight

          rts



.pend

CacheAOELeftHitbox .proc

          ;; Cache left-facing AOE bounds for current attacker
          ;; Returns: Near (return thisbank) - called same-bank

          ;; Input: temp1 = attacker index, characterIndex = character ID

          ;; Output: cachedHitboxLeft/Right/Top/Bottom populated

                    ;; let aoeOffset = CharacterAOEOffsets[characterIndex]          lda characterIndex          asl          tax          lda CharacterAOEOffsets,x          sta aoeOffset

          ;; let cachedHitboxRight_W = playerX[temp1] + PlayerSpriteWidth - 1 - aoeOffset
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerX,x (duplicate)
          ;; sta cachedHitboxRight_W (duplicate)

          ;; ;; let cachedHitboxLeft_W = cachedHitboxRight_R - PlayerSpriteHalfWidth          lda cachedHitboxRight_R          sec          sbc PlayerSpriteHalfWidth          sta cachedHitboxLeft_W
          ;; lda cachedHitboxRight_R (duplicate)
          sec
          sbc PlayerSpriteHalfWidth
          ;; sta cachedHitboxLeft_W (duplicate)

          ;; lda cachedHitboxRight_R (duplicate)
          ;; sec (duplicate)
          ;; sbc PlayerSpriteHalfWidth (duplicate)
          ;; sta cachedHitboxLeft_W (duplicate)


                    ;; let cachedHitboxTop_W = playerY[temp1]
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; sta cachedHitboxTop_W (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; sta cachedHitboxTop_W (duplicate)

                    ;; let cachedHitboxBottom_W = cachedHitboxTop_R + PlayerSpriteHeight

          ;; rts (duplicate)



.pend

CheckPlayersAgainstCachedHitbox .proc


          ;; Shared defender scan for missile/AOE collisions
          ;; Returns: Near (return thisbank) - called same-bank

          ;; Input: temp1 = attacker index, cachedHitbox* = attacker bounds

          ;; Output: temp4 = hit player index or MissileHitNotFound
          ;; lda MissileHitNotFound (duplicate)
          ;; sta temp4 (duplicate)

          ;; TODO: for temp2 = 0 to 3

          ;; lda temp2 (duplicate)
          ;; cmp temp1 (duplicate)
          ;; bne skip_5252 (duplicate)
          ;; TODO: CPB_NextPlayer
skip_5252:


                    ;; if playerHealth[temp2] = 0 then CPB_NextPlayer

                    ;; if playerX[temp2] + PlayerSpriteWidth <= cachedHitboxLeft_R then CPB_NextPlayer
          ;; lda temp2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerX,x (duplicate)
          clc
          adc PlayerSpriteWidth
          ;; sta temp6 (duplicate)
          ;; lda temp6 (duplicate)
          ;; sec (duplicate)
          ;; sbc cachedHitboxLeft_R (duplicate)
          bcc CPB_NextPlayer
          beq CPB_NextPlayer
          ;; jmp skip_9492 (duplicate)
CPB_NextPlayer:
skip_9492:

                    ;; if playerX[temp2] >= cachedHitboxRight_R then CPB_NextPlayer
          ;; lda temp2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerX,x (duplicate)
          ;; sec (duplicate)
          ;; sbc cachedHitboxRight_R (duplicate)
          ;; bcc skip_3163 (duplicate)
          ;; jmp CPB_NextPlayer (duplicate)
skip_3163:

                    ;; if playerY[temp2] + PlayerSpriteHeight <= cachedHitboxTop_R then CPB_NextPlayer
          ;; lda temp2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; clc (duplicate)
          ;; adc PlayerSpriteHeight (duplicate)
          ;; sta temp6 (duplicate)
          ;; lda temp6 (duplicate)
          ;; sec (duplicate)
          ;; sbc cachedHitboxTop_R (duplicate)
          ;; bcc CPB_NextPlayer (duplicate)
          ;; beq CPB_NextPlayer (duplicate)
          ;; jmp skip_8040 (duplicate)
;; CPB_NextPlayer: (duplicate)
skip_8040:

                    ;; if playerY[temp2] >= cachedHitboxBottom_R then CPB_NextPlayer
          ;; lda temp2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; sec (duplicate)
          ;; sbc cachedHitboxBottom_R (duplicate)
          ;; bcc skip_9459 (duplicate)
          ;; jmp CPB_NextPlayer (duplicate)
skip_9459:
          ;; lda temp2 (duplicate)
          ;; sta temp4 (duplicate)

          ;; rts (duplicate)

.pend

;; CPB_NextPlayer .proc (duplicate)

;; .pend (no matching .proc)

next_label_1_L693:.proc

          ;; jsr BS_return (duplicate)

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

                    ;; let temp2 = missileX[temp1]          lda temp1          asl          tax          lda missileX,x          sta temp2

                    ;; let temp3 = missileY_R[temp1]
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda missileY_R,x (duplicate)
          ;; sta temp3 (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda missileY_R,x (duplicate)
          ;; sta temp3 (duplicate)



          ;; Convert × to playfield coordinates

          ;; Playfield is 32 pf-pixels wide (4px wide each, so 128 screen pixels)



          ;; Convert × pixel to playfield column

          ;; ;; let temp6 = temp2 - 16          lda temp2          sec          sbc 16          sta temp6
          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc 16 (duplicate)
          ;; sta temp6 (duplicate)

          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc 16 (duplicate)
          ;; sta temp6 (duplicate)


          ;; ;; let temp6 = temp6 / 4          lda temp6          lsr          lsr          sta temp6
          ;; lda temp6 (duplicate)
          lsr
          ;; lsr (duplicate)
          ;; sta temp6 (duplicate)

          ;; lda temp6 (duplicate)
          ;; lsr (duplicate)
          ;; lsr (duplicate)
          ;; sta temp6 (duplicate)




          ;; Check if playfield pixel is set at missile position

          ;; Assume clear until pfread says otherwise

          ;; lda # 0 (duplicate)
          ;; sta temp4 (duplicate)

          ;; lda temp6 (duplicate)
          ;; sta temp1 (duplicate)

          ;; lda temp3 (duplicate)
          ;; sta temp2 (duplicate)

          ;; Cross-bank call to PlayfieldRead in bank 16
          ;; lda # >(return_point_1_L825-1) (duplicate)
          pha
          ;; lda # <(return_point_1_L825-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
                    ldx # 15
          ;; jmp BS_jsr (duplicate)
return_point_1_L825:


          ;; pfread(column, row) returns 0 if clear, non-zero if set

          ;; jsr BS_return (duplicate)

          ;; Clear

          ;; jsr BS_return (duplicate)



;; .pend (extra - no matching .proc)

