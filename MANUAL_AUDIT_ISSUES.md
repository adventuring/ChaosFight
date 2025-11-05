# Manual Audit - Issues Found

## Technical Terms to Remove/Replace

### 1. "sprite" usage (2 instances)
- Line 270: "The screen shows character sprites in fixed positions"
- Line 281: "Playfield border appears around locked sprite"
- **Fix**: Replace with "characters" or "character images"

### 2. "projectile" usage (3 instances)
- CurlingSweeper.texi line 6: "Special: Projectile comes from character's feet"
- DragonOfStorms.texi line 6: "Special: Fires projectiles that arc upward"
- DragonOfStorms.texi line 22: "fires projectiles that arc upward"
- **Fix**: Replace with "attack" or "curling stone" / "fireballs"

### 3. "missile" usage (1 instance)
- ZoeRyen.texi line 10: "fires a long, thin missile"
- **Fix**: Replace with "attack" or "laser"

## Spelling Inconsistencies

### "Melee" vs "Melée" vs "Melée"
- Various files use different spellings
- **Question**: Which spelling should be standard? "Melee", "Melée", or "Melée"?

## Grammar/Style Issues

### 1. Harpy.texi line 28-29
- Current: "The Harpy can maintain flight by repeatedly flapping her wings (jump button or up on the joystick)"
- **Issue**: Parenthetical is awkward, could be clearer

### 2. RoboTito.texi line 29
- Current: "In ChaosFight, he is vulnerable the entire length to collisions."
- **Issue**: Awkward phrasing - "vulnerable the entire length" is unclear

### 3. Character Selection line 270
- Current: "The screen shows character sprites in fixed positions:"
- **Issue**: Incomplete sentence (no following content)

### 4. Weight inconsistencies
- Bernie: Shows 5 kg (10 lbs) - need to verify correct weight
- Need to check all weights for consistency

## Content Accuracy Questions

### 1. Harpy Attack Type
- Manual says: "Attack: Melée (diagonal swoop)"
- **Question**: Is Harpy's attack melée or ranged? The attack involves movement, not a projectile. Should it be described differently?

### 2. Ursulo Attack Description
- Manual says: "Attack: Melee (claw swipe)" but also mentions "powerful melee claw swipe attack"
- **Question**: Is this redundant? Should it just be "Melee" or "Melee (claw swipe)"?

### 3. Character Special Abilities
- **Question**: Are all special abilities accurately described? Any missing or incorrect?

### 4. Game Controls
- **Question**: Are all control descriptions accurate? Any missing controls?

### 5. Victory Conditions
- **Question**: Are victory conditions accurately described in the manual?

## Style/Level of Detail Questions

### 1. Technical Details
- **Question**: Should we remove mentions of "ground-based", "horizontal", "arc upward" etc. and just describe what the attack does simply?

### 2. Character Descriptions
- **Question**: Are the narrative descriptions appropriate length, or should some be shortened?

### 3. Weight Information
- **Question**: Is weight information necessary for players, or should it be removed?

### 4. Original Game References
- **Question**: Should we keep all the original game purchase/download/forum links, or simplify?

## Missing Information Questions

### 1. Arena Selection
- **Question**: How does arena selection work? Is it described in the manual?

### 2. CPU Player Behavior
- **Question**: How does the CPU player behave? Is this documented?

### 3. Knockback Mechanics
- **Question**: Are knockback mechanics described? Should they be?

### 4. Special Character Mechanics
- **Question**: Are all special character mechanics (like RoboTito's stretch, Frooty's flight) fully explained?

