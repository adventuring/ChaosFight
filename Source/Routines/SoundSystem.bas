          rem ChaosFight - Source/Routines/SoundSystem.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem =================================================================
          rem SOUND EFFECTS SYSTEM
          rem =================================================================
          rem Provides sound effects for various game events
          rem Uses AUDC1 for sound effects (AUDC0 reserved for music)

          rem =================================================================
          rem SOUND EFFECT CONSTANTS
          rem =================================================================
          const SoundAttack = 1
          const SoundHit = 2
          const SoundFall = 3
          const SoundGuard = 4
          const SoundSelect = 5
          const SoundVictory = 6
          const SoundElimination = 7

          rem =================================================================
          rem SOUND EFFECT DATA TABLES
          rem =================================================================
          rem Attack sound (melee swoosh)
          data AttackSoundData
          $0C, $0A, $08, $06, $04, $02, $00
          end

          data AttackSoundFreq
          $1F, $1C, $19, $16, $13, $10, $0D
          end

          rem Hit sound (impact)
          data HitSoundData
          $0F, $0D, $0B, $09, $07, $05, $03, $01
          end

          data HitSoundFreq
          $1A, $18, $16, $14, $12, $10, $0E, $0C
          end

          rem Fall damage sound
          data FallSoundData
          $0E, $0C, $0A, $08, $06, $04, $02, $00
          end

          data FallSoundFreq
          $15, $13, $11, $0F, $0D, $0B, $09, $07
          end

          rem Guard activation sound
          data GuardSoundData
          $0A, $08, $06, $04, $02
          end

          data GuardSoundFreq
          $1C, $1A, $18, $16, $14
          end

          rem Character selection sound
          data SelectSoundData
          $0C, $0A, $08, $06
          end

          data SelectSoundFreq
          $1E, $1C, $1A, $18
          end

          rem Victory sound
          data VictorySoundData
          $0F, $0D, $0B, $09, $07, $05, $03, $01, $00
          end

          data VictorySoundFreq
          $1F, $1D, $1B, $19, $17, $15, $13, $11, $0F
          end

          rem Elimination sound (dramatic death sound)
          data EliminationSoundData
          $0F, $0E, $0D, $0C, $0B, $0A, $09, $08, $07, $06, $05, $04, $03, $02, $01, $00
          end

          data EliminationSoundFreq
          $18, $16, $14, $12, $10, $0E, $0C, $0A, $08, $06, $05, $04, $03, $02, $01, $00
          end

          rem =================================================================
          rem SOUND PLAYBACK FUNCTIONS
          rem =================================================================

          rem Play attack sound effect
          rem Input: temp1 = sound type (1-6)
PlaySoundEffect
          if temp1 = SoundAttack then goto PlayAttackSound
          if temp1 = SoundHit then goto PlayHitSound
          if temp1 = SoundFall then goto PlayFallSound
          if temp1 = SoundGuard then goto PlayGuardSound
          if temp1 = SoundSelect then goto PlaySelectSound
          if temp1 = SoundVictory then goto PlayVictorySound
          if temp1 = SoundElimination then goto PlayEliminationSound
          return

          rem Play attack sound (melee swoosh)
PlayAttackSound
          temp2 = 0
          temp3 = 7 
          rem 7 frames
AttackSoundLoop
          if temp2 >= temp3 then return
          
          temp4 = AttackSoundData(temp2)
          temp5 = AttackSoundFreq(temp2)
          AUDC1 = temp4
          AUDF1 = temp5
          
          temp2 = temp2 + 1
          goto AttackSoundLoop

          rem Play hit sound (impact)
PlayHitSound
          temp2 = 0
          temp3 = 8 
          rem 8 frames
HitSoundLoop
          if temp2 >= temp3 then return
          
          temp4 = HitSoundData(temp2)
          temp5 = HitSoundFreq(temp2)
          AUDC1 = temp4
          AUDF1 = temp5
          
          temp2 = temp2 + 1
          goto HitSoundLoop

          rem Play fall damage sound
PlayFallSound
          temp2 = 0
          temp3 = 8 
          rem 8 frames
FallSoundLoop
          if temp2 >= temp3 then return
          
          temp4 = FallSoundData(temp2)
          temp5 = FallSoundFreq(temp2)
          AUDC1 = temp4
          AUDF1 = temp5
          
          temp2 = temp2 + 1
          goto FallSoundLoop

          rem Play guard activation sound
PlayGuardSound
          temp2 = 0
          temp3 = 5 
          rem 5 frames
GuardSoundLoop
          if temp2 >= temp3 then return
          
          temp4 = GuardSoundData(temp2)
          temp5 = GuardSoundFreq(temp2)
          AUDC1 = temp4
          AUDF1 = temp5
          
          temp2 = temp2 + 1
          goto GuardSoundLoop

          rem Play character selection sound
PlaySelectSound
          temp2 = 0
          temp3 = 4 
          rem 4 frames
SelectSoundLoop
          if temp2 >= temp3 then return
          
          temp4 = SelectSoundData(temp2)
          temp5 = SelectSoundFreq(temp2)
          AUDC1 = temp4
          AUDF1 = temp5
          
          temp2 = temp2 + 1
          goto SelectSoundLoop

          rem Play victory sound
PlayVictorySound
          temp2 = 0
          temp3 = 9 
          rem 9 frames
VictorySoundLoop
          if temp2 >= temp3 then return
          
          temp4 = VictorySoundData(temp2)
          temp5 = VictorySoundFreq(temp2)
          AUDC1 = temp4
          AUDF1 = temp5
          
          temp2 = temp2 + 1
          goto VictorySoundLoop

          rem Play elimination sound (dramatic death sound)
PlayEliminationSound
          temp2 = 0
          temp3 = 16 
          rem 16 frames
EliminationSoundLoop
          if temp2 >= temp3 then return
          
          temp4 = EliminationSoundData(temp2)
          temp5 = EliminationSoundFreq(temp2)
          AUDC1 = temp4
          AUDF1 = temp5
          
          temp2 = temp2 + 1
          goto EliminationSoundLoop

          rem Stop all sound effects
StopSoundEffects
          AUDC1 = 0
          AUDF1 = 0
          return
