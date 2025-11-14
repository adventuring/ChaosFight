          rem ChaosFight - Source/Routines/CharacterSelectFire.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Character select fire handling moved for bank optimization

HandleCharacterSelectFire
          asm
HandleCharacterSelectFire

end
          rem Handle fire input (selection)
          rem
          rem Handle fire input (selection) for a player
          rem
          rem Input: temp1 = player index (0-3)
          rem        joy0fire/joy0down (players 0,2) or joy1fire/joy1down (players 1,3)
          rem        playerCharacter[] (global array) = current character selections
          rem        randomSelectFlags[] (global array) = random selection flags
          rem Output: playerLocked state updated, randomSelectFlags[] updated if random selected
          rem
          rem Mutates: playerLocked state (set to normal or handicap),
          rem randomSelectFlags[] (if random),
          rem         temp1, temp2, temp3, temp4 (passed to helper
          rem         routines)
          rem
          rem Called Routines: SetPlayerLocked (bank6) - accesses
          rem playerLocked state,
          rem   PlaySoundEffect (bank15) - plays selection sound
          rem
          rem Constraints: Must be colocated with HCSF_CheckJoy0,
          rem HCSF_HandleFire,
          rem HCSF_HandleHandicap, HCSF_HandleRandom (all called via goto)
          rem Determine which joy port to use
          if temp1 = 0 then HCSF_CheckJoy0
          if temp1 = 2 then HCSF_CheckJoy0
          rem Players 1,3 use joy1
          if !joy1fire then return
          let temp2 = 1
          if joy1down then temp4 = 1 : goto HCSF_HandleFire
          let temp4 = 0
          goto HCSF_HandleFire
HCSF_CheckJoy0
          rem Check joy0 for players 0,2
          rem
          rem Input: temp1 (from HandleCharacterSelectFire)
          rem        joy0fire, joy0down (hardware) = joystick states
          rem
          rem Output: Dispatches to HCSF_HandleFire or returns
          rem
          rem Mutates: temp2, temp4
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with
          rem HandleCharacterSelectFire
          rem Players 0,2 use joy0
          if !joy0fire then return
          let temp2 = 1
          if joy0down then temp4 = 1 : goto HCSF_HandleFire
          let temp4 = 0
HCSF_HandleFire
          rem Handle fire button press
          rem
          rem Input: temp1, temp4 (from
          rem HandleCharacterSelectFire)
          rem        playerCharacter[] (global array) = current character
          rem        selections
          rem
          rem Output: Dispatches to HCSF_HandleRandom,
          rem HCSF_HandleHandicap, or locks normally
          rem
          rem Mutates: playerLocked state, randomSelectFlags[] (if
          rem random)
          rem
          rem Called Routines: SetPlayerLocked (bank6),
          rem PlaySoundEffect (bank15)
          rem
          rem Constraints: Must be colocated with
          rem HandleCharacterSelectFire
          rem Check if RandomCharacter selected
          if playerCharacter[temp1] = RandomCharacter then goto HCSF_HandleRandom
          rem Check for handicap mode (down+fire = 75% health)
          if temp4 then HCSF_HandleHandicap
          let temp3 = temp1
          let temp1 = temp3
          let temp2 = PlayerLockedNormal
          gosub SetPlayerLocked
          let temp1 = SoundMenuSelect
          rem Play selection sound
          gosub PlaySoundEffect bank15
          return
HCSF_HandleHandicap
          rem Handle handicap mode selection (75% health)
          rem
          rem Input: temp1 (from HandleCharacterSelectFire)
          rem
          rem Output: playerLocked state set to handicap
          rem
          rem Mutates: playerLocked state (set to handicap)
          rem
          rem Called Routines: SetPlayerLocked (bank6),
          rem PlaySoundEffect (bank15)
          rem Constraints: Must be colocated with HandleCharacterSelectFire
          let temp3 = temp1
          let temp1 = temp3
          let temp2 = PlayerHandicapped
          gosub SetPlayerLocked
          let temp1 = SoundMenuSelect
          rem Play selection sound
          gosub PlaySoundEffect bank15
          return

HCSF_HandleRandom
          rem Handle random character selection
          rem
          rem Input: temp1, temp4 (from
          rem HandleCharacterSelectFire)
          rem        randomSelectFlags[] (global array) = random
          rem        selection flags
          rem
          rem Output: randomSelectFlags[temp1] set, selection
          rem sound played
          rem
          rem Mutates: randomSelectFlags[temp1] (set to $80
          rem if handicap, 0 otherwise)
          rem
          rem Called Routines: PlaySoundEffect (bank15)
          rem
          rem Constraints: Must be colocated with
          rem HandleCharacterSelectFire
          rem Random selection initiated - will be handled by
          rem CharacterSelectHandleRandomRolls
          rem Store handicap flag if down was held
          if temp4 then let randomSelectFlags_W[temp1] = TRUE : goto HCSF_HandleRandomSound
          let randomSelectFlags_W[temp1] = 0
HCSF_HandleRandomSound
          let temp1 = SoundMenuSelect
          rem Play selection sound
          gosub PlaySoundEffect bank15
          rem Fall through - character will stay as RandomCharacter
          rem until roll succeeds
          return

