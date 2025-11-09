          rem ChaosFight - Source/Routines/AnimationHelpers.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Small animation helper functions moved for bank optimization

SetIdleAnimation
          rem Set idle animation for a player
          rem
          rem INPUT: currentPlayer = player index (0-3)
          rem
          rem OUTPUT: None
          rem EFFECTS: Changes player animation to ActionIdle state
          let temp2 = ActionIdle
          gosub SetPlayerAnimation bank11
          return
SetWalkingAnimation
          rem
          rem Animation Sequence Management
          rem Set walking animation for a player
          rem
          rem INPUT: currentPlayer = player index (0-3)
          rem
          rem OUTPUT: None
          rem EFFECTS: Changes player animation to ActionWalking state
          let temp2 = ActionWalking
          gosub SetPlayerAnimation bank11
          return

