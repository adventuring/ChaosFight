          rem ChaosFight - Source/Common/AssemblyConfig.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Assembly configuration symbols for batariBASIC-generated code
          rem These are included at the top of the generated assembly file

          rem Bankswitching configuration
          rem Note: batariBASIC automatically defines bankswitch from set romsize,
          rem   but we explicitly define it here to ensure it’s available in assembler
          const bankswitch = 64
          rem EF bankswitching (64KiB with SuperChip RAM)

          rem Kernel configuration
          rem Note: Most of these are automatically defined by batariBASIC based on
          rem   set kernel and set romsize commands, but pfres must be defined manually
          const pfres = 8
          rem Playfield resolution: 8 rows (fixed for all playfields)

          rem ==========================================================
          rem Constant EQU Definitions (Workaround for Issue #739)
          rem ==========================================================
          rem batariBASIC doesn't inline constants, generating LDA PlayerHealthMax
          rem instead of LDA #100. These EQU definitions allow dasm to resolve
          rem the symbols at assembly time.
          rem Note: These must match the const definitions in Constants.bas
          asm
; Constant EQU definitions for batariBASIC constants that aren't inlined
    ActionAttackWindup = 13
    ActionHit = 5
    ActionRecovering = 9
    ActionStanding = 0
    ActionWalking = 3
    CharDragonOfStorms = 2
    CharFrooty = 8
    CharHarpy = 6
    CharKnightGuy = 7
    CharMegax = 5
    CharRoboTito = 13
    FramesPerSecond = 60
    GravityNormal = 26
    GravityPerFrame = 1
    GravityReduced = 13
    HitstunFrames = 10
    KnockbackImpulse = 4
    MaxByteValue = 255
    MaxCharacter = 15
    MinimumVelocityThreshold = 1
    MissileAABBSize = 4
    MissileFlagBounce = 8
    MissileFlagFriction = 16
    MissileFlagGravity = 4
    MissileFlagHitBackground = 1
    MissileHitNotFound = 255
    MissileLifetimeInfinite = 255
    MissileSpawnOffsetLeft = 4
    MissileSpawnOffsetRight = 12
    ModeAuthorPrelude = 1
    ModeCharacterSelect = 3
    ModePublisherPrelude = 0
    ModeTitle = 2
    MusicAtariToday = 27
    MusicChaotica = 26
    MusicInterworldly = 28
    NoCharacter = 255
    NUSIZMaskReflection = 191
    PlayerEliminatedPlayer2 = 4
    PlayerEliminatedPlayer3 = 8
    PlayerHealthMax = 100
    PlayerLockedHandicap = 2
    PlayerLockedNormal = 1
    PlayerLockedUnlocked = 0
    PlayerSpriteHalfWidth = 8
    PlayerSpriteHeight = 16
    PlayerSpriteWidth = 16
    PlayerStateBitFacing = 8
    PlayerStateBitFacingNUSIZ = 64
    PlayerStateBitJumping = 4
    PlayerStateBitRecovery = 1
    RandomArena = 255
    ScreenBottom = 192
    ScreenInsetX = 16
    ScreenTopWrapThreshold = 200
    SetPlayers34Active = $40
    SetQuadtariDetected = $80
    SoundAttackHit = 0
    SoundGuardBlock = 1
    SystemFlagColorBWOverride = $40
    TerminalVelocity = 8
end

