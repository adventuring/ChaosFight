          rem ChaosFight - Source/Routines/MissileCollision.bas

          rem Copyright © 2025 Bruce-Robert Pocock.



CheckAllMissileCollisions
          rem Returns: Far (return otherbank)

          asm

CheckAllMissileCollisions

end

          rem Missile Collision System
          rem Returns: Far (return otherbank)

          rem Handles all collision detection for missiles and

          rem   area-of-effect attacks.

          rem COLLISION TYPES:

          rem 1. Missile-to-Player: Visible missiles (ranged or mêlée

          rem   visuals)

          rem 2. AOE-to-Player: Mêlée attacks with no visible missile

          rem   (0×0 size)

          rem 3. Missile-to-Playfield: For missiles that interact with

          rem   walls

          rem SPECIAL CASES:

          rem   - Bernie: AOE extends both left AND right simultaneously

          rem   - Other mêlée: AOE only in facing direction

          rem

          rem FACING DIRECTION FORMULA (for AOE attacks):

          rem   Facing right (bit 0 = 1): AOE_X = playerX + offset

          rem   Facing left  (bit 0 = 0): AOE_X = playerX + 7 - offset

          rem Check all missile collisions (visible missiles and AOE) each frame.

          rem Input: temp1 = attacker player index (0-3)

          rem        missileActive (global) = missile active flags

          rem        playerCharacter[] (global) = character types

          rem Output: temp4 = hit player index (0-3) if hit, MissileHitNotFound otherwise

          rem Mutates: temp1-temp6, temp4

          rem

          rem Called Routines: CheckVisibleMissileCollision (tail call) - if visible

          rem missile, CheckAOECollision (goto) - if AOE attack,

          rem CheckPlayersAgainstCachedHitbox - shared defender scan

          rem Constraints: None

          rem Optimized: Calculate missile active bit flag with formula

          rem Bit flag: BitMask[playerIndex] (1, 2, 4, 8 for players 0-3)

          let temp4 = MissileHitNotFound

          let temp6 = BitMask[temp1]

          let temp5 = missileActive & temp6

          rem No active missile

          if temp5 = 0 then return otherbank



          rem Cache character index for downstream routines

          let characterIndex = playerCharacter[temp1]



          rem Visible missile when width > 0, otherwise treat as AOE

          let temp6 = CharacterMissileWidths[characterIndex]

          if temp6 = 0 then goto CheckAOECollision

          rem tail call

          goto CheckVisibleMissileCollision





CheckVisibleMissileCollision
          rem Returns: Near (return thisbank) - called same-bank

          asm

CheckVisibleMissileCollision

end

          rem
          rem Returns: Far (return otherbank)

          rem Check Visible Missile Collision

          rem Checks collision between a visible missile and all

          rem   players.

          rem Uses axis-aligned bounding box (AABB) collision detection.

          rem

          rem INPUT:

          rem   temp1 = attacker player index (0-3, missile owner)

          rem

          rem OUTPUT:

          rem   temp4 = hit player index (0-3), or 255 if no hit

          rem Checks collision between a visible missile and all players

          rem using AABB collision detection

          rem

          rem Input: temp1 = attacker player index (0-3, missile owner),

          rem missileX[] (global array) = missile X positions,

          rem missileY_R[] (global SCRAM array) = missile Y positions,

          rem playerCharacter[] (global array) = character types, playerX[],

          rem playerY[] (global arrays) = player positions,

          rem playerHealth[] (global array) = player health

          rem

          rem Output: temp4 = hit player index (0-3) if hit, 255 if no

          rem hit

          rem

          rem Mutates: temp1-temp6 (used for calculations), temp4

          rem (return value)

          rem

          rem Called Routines: CheckPlayersAgainstCachedHitbox - scans defenders

          rem Constraints: None

          rem Ensure character index matches current attacker

          let characterIndex = playerCharacter[temp1]



          let cachedHitboxLeft_W = missileX[temp1]

          let cachedHitboxTop_W = missileY_R[temp1]



          rem Derive hitbox bounds from missile dimensions

          let temp6 = CharacterMissileWidths[characterIndex]

          let cachedHitboxRight_W = cachedHitboxLeft_R + temp6

          let temp6 = CharacterMissileHeights[characterIndex]

          let cachedHitboxBottom_W = cachedHitboxTop_R + temp6



          gosub CheckPlayersAgainstCachedHitbox

          return otherbank



CheckAOECollision
          rem Returns: Near (return thisbank) - called same-bank

          asm

CheckAOECollision

end

          rem
          rem Returns: Far (return otherbank)

          rem Check Aoe Collision

          rem Checks collision for area-of-effect mêlée attacks (no

          rem   visible missile).

          rem AOE is relative to player position and facing direction.

          rem SPECIAL CASE: Bernie (character 0) Ground Thump attack

          rem   hits both left AND right simultaneously, shoving enemies

          rem   away rapidly.

          rem

          rem INPUT:

          rem   temp1 = attacker player index (0-3)

          rem

          rem OUTPUT:

          rem   temp4 = hit player index (0-3), or 255 if no hit

          rem Checks collision for area-of-effect mêlée attacks (no

          rem visible missile)

          rem

          rem Input: temp1 = attacker player index (0-3), playerCharacter[]

          rem (global array) = character types, playerState[] (global

          rem array) = player states (bit 0 = facing), playerX[],

          rem playerY[] (global arrays) = player positions,

          rem playerHealth[] (global array) = player health,

          rem CharacterAOEOffsets[] (global data table) = AOE offsets

          rem

          rem Output: temp4 = hit player index (0-3) if hit, 255 if no

          rem hit

          rem

          rem Mutates: temp1-temp6 (used for calculations), temp4

          rem (return value)

          rem

          rem Called Routines: CheckAOEDirection_Right - checks AOE

          rem collision facing right, CheckAOEDirection_Left - checks

          rem AOE collision facing left, CheckBernieAOE - special case

          rem for Bernie (hits both directions)

          rem Constraints: Bernie (character 0) hits both left AND right simultaneously

          let characterIndex = playerCharacter[temp1]

          rem Get attacker character type

          let temp5 = characterIndex



          rem Check if this is Bernie (character 0)

          rem Bernie attacks both left AND right, so check both

          rem directions

          if temp5 = CharacterBernie then CheckBernieAOE



          rem Normal character: Check only facing direction

          let temp6 = playerState[temp1] & PlayerStateBitFacing

          if temp6 = 0 then goto CheckAOEDirection_Left

          goto CheckAOEDirection_Right



CheckBernieAOE
          rem Returns: Far (return otherbank)

          asm

CheckBernieAOE

end

          rem Bernie swings both directions every frame
          rem Returns: Far (return otherbank)

          gosub CacheAOERightHitbox

          gosub CheckPlayersAgainstCachedHitbox

          if temp4 <> MissileHitNotFound then return otherbank



          gosub CacheAOELeftHitbox

          gosub CheckPlayersAgainstCachedHitbox

          return otherbank

          

CheckAOEDirection_Right
          rem Returns: Near (return thisbank) - called same-bank

          asm

CheckAOEDirection_Right

end

          rem
          rem Returns: Near (return thisbank) - called same-bank

          rem Check Aoe Direction - Right

          rem Checks AOE collision when attacking to the right.

          rem Formula: AOE_X = playerX + offset

          rem

          rem INPUT:

          rem   temp1 = attacker player index (0-3)

          rem

          rem OUTPUT:

          rem   temp4 = hit player index (0-3), or 255 if no hit

          rem Checks AOE collision when attacking to the right (AOE_X =

          rem playerX + offset)

          rem

          rem Input: temp1 = attacker player index (0-3), playerX[],

          rem playerY[] (global arrays) = player positions, playerCharacter[]

          rem (global array) = character types, playerHealth[] (global

          rem array) = player health, CharacterAOEOffsets[] (global data

          rem table) = AOE offsets

          rem

          rem Output: temp4 = hit player index (0-3) if hit, 255 if no

          rem hit

          rem

          rem Mutates: temp1-temp6 (used for calculations), temp4

          rem (return value)

          rem

          rem Called Routines: None

          rem Constraints: None

          gosub CacheAOERightHitbox

          gosub CheckPlayersAgainstCachedHitbox

          return otherbank



CheckAOEDirection_Left
          rem Returns: Near (return thisbank) - called same-bank

          asm

CheckAOEDirection_Left

end

          rem
          rem Returns: Near (return thisbank) - called same-bank

          rem Check Aoe Direction - Left

          rem Checks AOE collision when attacking to the left.

          rem Formula: AOE_X = playerX + 7 - offset

          rem

          rem INPUT:

          rem   temp1 = attacker player index (0-3)

          rem

          rem OUTPUT:

          rem   temp4 = hit player index (0-3), or 255 if no hit

          rem Checks AOE collision when attacking to the left (AOE_X =

          rem playerX + 7 - offset)

          rem

          rem Input: temp1 = attacker player index (0-3), playerX[],

          rem playerY[] (global arrays) = player positions, playerCharacter[]

          rem (global array) = character types, playerHealth[] (global

          rem array) = player health, CharacterAOEOffsets[] (global data

          rem table) = AOE offsets

          rem

          rem Output: temp4 = hit player index (0-3) if hit, 255 if no

          rem hit

          rem

          rem Mutates: temp1-temp6 (used for calculations), temp4

          rem (return value)

          rem

          rem Called Routines: None

          rem Constraints: None

          gosub CacheAOELeftHitbox

          gosub CheckPlayersAgainstCachedHitbox

          return otherbank



CacheAOERightHitbox
          rem Returns: Near (return thisbank) - called same-bank
          asm

CacheAOERightHitbox

end
          rem Cache right-facing AOE bounds for current attacker
          rem Returns: Near (return thisbank) - called same-bank

          rem Input: temp1 = attacker index, characterIndex = character ID

          rem Output: cachedHitboxLeft/Right/Top/Bottom populated

          let aoeOffset = CharacterAOEOffsets[characterIndex]

          let cachedHitboxLeft_W = playerX[temp1] + aoeOffset

          let cachedHitboxRight_W = cachedHitboxLeft_R + PlayerSpriteHalfWidth

          let cachedHitboxTop_W = playerY[temp1]

          let cachedHitboxBottom_W = cachedHitboxTop_R + PlayerSpriteHeight

          return thisbank



CacheAOELeftHitbox
          rem Returns: Near (return thisbank) - called same-bank
          asm

CacheAOELeftHitbox

end
          rem Cache left-facing AOE bounds for current attacker
          rem Returns: Near (return thisbank) - called same-bank

          rem Input: temp1 = attacker index, characterIndex = character ID

          rem Output: cachedHitboxLeft/Right/Top/Bottom populated

          let aoeOffset = CharacterAOEOffsets[characterIndex]

          let cachedHitboxRight_W = playerX[temp1] + PlayerSpriteWidth - 1 - aoeOffset

          let cachedHitboxLeft_W = cachedHitboxRight_R - PlayerSpriteHalfWidth

          let cachedHitboxTop_W = playerY[temp1]

          let cachedHitboxBottom_W = cachedHitboxTop_R + PlayerSpriteHeight

          return thisbank



CheckPlayersAgainstCachedHitbox
          rem Returns: Near (return thisbank) - called same-bank
          asm

CheckPlayersAgainstCachedHitbox

end

          rem Shared defender scan for missile/AOE collisions
          rem Returns: Near (return thisbank) - called same-bank

          rem Input: temp1 = attacker index, cachedHitbox* = attacker bounds

          rem Output: temp4 = hit player index or MissileHitNotFound

          let temp4 = MissileHitNotFound

          for temp2 = 0 to 3

          if temp2 = temp1 then CPB_NextPlayer

          if playerHealth[temp2] = 0 then CPB_NextPlayer

          if playerX[temp2] + PlayerSpriteWidth <= cachedHitboxLeft_R then CPB_NextPlayer

          if playerX[temp2] >= cachedHitboxRight_R then CPB_NextPlayer

          if playerY[temp2] + PlayerSpriteHeight <= cachedHitboxTop_R then CPB_NextPlayer

          if playerY[temp2] >= cachedHitboxBottom_R then CPB_NextPlayer

          let temp4 = temp2

          return thisbank

CPB_NextPlayer

          next

          return otherbank

MissileCollPF
          rem Returns: Far (return otherbank)

          asm

MissileCollPF

end

          rem
          rem Returns: Far (return otherbank)

          rem Check Missile-playfield Collision

          rem Checks if missile hit the playfield (walls, obstacles).

          rem Uses pfread to check playfield pixel at missile position.

          rem

          rem INPUT:

          rem   temp1 = player index (0-3)

          rem

          rem OUTPUT:

          rem   temp4 = 1 if hit playfield, 0 if clear

          rem Checks if missile hit the playfield (walls, obstacles)

          rem using pfread

          rem

          rem Input: temp1 = player index (0-3), missileX[] (global

          rem array) = missile X positions, missileY_R[] (global SCRAM

          rem array) = missile Y positions

          rem

          rem Output: temp4 = 1 if hit playfield, 0 if clear

          rem

          rem Mutates: temp2 (used for missile X), temp3 (used for

          rem missile Y), temp4 (return value), temp6 (used for

          rem playfield column calculation)

          rem

          rem Called Routines: None

          rem

          rem Constraints: None

          rem Get missile X/Y position

          let temp2 = missileX[temp1]

          let temp3 = missileY_R[temp1]



          rem Convert × to playfield coordinates

          rem Playfield is 32 pf-pixels wide (4px wide each, so 128 screen pixels)

          

          rem Convert × pixel to playfield column

          let temp6 = temp2 - 16

          let temp6 = temp6 / 4



          rem Check if playfield pixel is set at missile position

          rem Assume clear until pfread says otherwise

          let temp4 = 0

          let temp1 = temp6

          let temp2 = temp3

          gosub PlayfieldRead bank16

          rem pfread(column, row) returns 0 if clear, non-zero if set

          if temp1 then let temp4 = $80 : return otherbank

          rem Clear

          return otherbank


