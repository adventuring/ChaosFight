;;; Chaos Fight Source/Common/Enums.bas
;;; Copyright 2025 Bruce-Robert Pocock

          ;; TV Standards (defined in Constants.s, not here)

          ;; Game Modes
          ModePublisherPrelude = 0
          ModeAuthorPrelude = 1
          ModeTitle = 2
          ModeCharacterSelect = 3
          ModeFallingAnimation = 4
          ModeArenaSelect = 5
          ModeGame = 6
          ModeWinner = 7
          ModeAttract = 8

          CharacterBernie = 0
          CharacterCurler = 1
          CharacterDragonOfStorms = 2
          CharacterZoeRyen = 3
          CharacterFatTony = 4
          CharacterMegax = 5
          CharacterHarpy = 6
          CharacterKnightGuy = 7
          CharacterFrooty = 8
          CharacterNefertem = 9
          CharacterNinjishGuy = 10
          CharacterPorkChop = 11
          CharacterRadishGoblin = 12
          CharacterRoboTito = 13
          CharacterUrsulo = 14
          CharacterShamone = 15






          CharacterMethHound = 31

          ;;
          ;; Animation Action Enums
          ;; 16 animation actions (0-15) stored in playerState bits 4-7
          ;; Used for character animation sequences
          ;; Each action has up to 8 frames (0-7)

          ActionStanding = 0
          ActionIdle = 1
          ActionGuarding = 2
          ActionWalking = 3
          ActionStopping = 4
          ActionHit = 5         ; being hit
          ActionFallBack = 6    ; knockback
          ActionFallDown = 7    ; starting to fall from no floor
          ActionFallen = 8      ; hit ground too hard
          ActionRecovering = 9  ; standing back up
          ActionJumping = 10
          ActionFalling = 11
          ActionLanding = 12    ; hit ground normal hard
          ActionAttackWindup = 13
          ActionAttackExecute = 14
          ActionAttackRecovery = 15

          ActionRoboTitoStretch = ActionJumping
          ActionRoboTitoLatched = ActionFallDown
          ActionRoboTitoRetract = ActionRecovering

          ;; Missile Flags Bitfield Encoding
          ;; bit flags for missile behavior (CharacterMissileFlags)
          ;; Used for checking missile interaction properties

          MissileFlagHitBackground = 1 ; vanish if hit playfield
          MissileFlagHitPlayer = 2     ; vanish if hit character
          MissileFlagGravity = 4       ; arc with gravity
          MissileFlagBounce = 8        ; bounce off playfield
          MissileFlagFriction = $10    ; curling stone friction

          MissileFlagHitBoth = MissileFlagHitBackground | MissileFlagHitPlayer
          MissileFlagHitBackgroundAndGravity = MissileFlagHitBackground | MissileFlagGravity
          MissileFlagCurler = MissileFlagFriction | MissileFlagHitBackground | MissileFlagHitPlayer | MissileFlagBounce
          MissileFlagCurlerFull = 31

          ;; Attack Type Constants (for CharacterAttackTypes data table and PlayerAttackType array)
          AttackMelee = 0
          AttackRanged = 1
          AttackArea = 2


          BankMusic = 0
          BankCharacterArt = 1  ; 1, 2, 3, 4
          BankCharSelect = 5
          BankCombat = 6
          BankPhysics = 7
          BankTitleScreen = 8
          BankSprites = 9
          BankGamePlay = 10
          BankCharacterInfo = 11
          BankInput = 12
          BankControl = 13
          BankMoreMusic = 14
          BankDrawScreen = 15
