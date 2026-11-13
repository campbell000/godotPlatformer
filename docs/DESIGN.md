I want a 2D platformer. It needs an NES aesthetic. I want a game that emphasis speed and flow state of platforming, but not autistic and doesnt rely on memorization. I find Super Mario games the most fun when I get through them as fast as possible. Sonic is too fast

# Tech Specs
- Arbitrary resolutions and framerates supported
- effective resolution is a widescreen NES game
- Godot
- Sub pixel movement is allowed
- Base resolution 384x216, integer scaled

# Artistic Specs
- Minimalist but not aggressively so
- Anime style (especially portraits when they are talking)
- Do not slavishly adhere to NES color scheme (i.e. allow more colors and sprites than what the NES could support) BUT I DO NOT want it to look like indie slop games that are hyper detailed with obnoxious color palettes and extremely smooth animation
- Creepy aesthetic but not necessarily creepy pasta
- Race sequence is an unsettling red current chasing you
- Ambient, but aggressive undertone music (except for chase sequences)
- Chase sequences are metal music or something similar

# Game Design
- Replayable in the sense that it's fun to go through most levels again
- Each level culminates in a timed race towards something (in the sense that something is after you)
- When this happens, it features a real piece of music
- Player can slide (slight speed boost, lowers hit box), walljump, wall slide, attack mid air (slight cancel of gravity), hold weapon downwards to bounce off of enemies
- Thrill of going fast and accomplishing fluid (sometimes difficult) platforming sections. 
- Attacking is necessary but not the focus (a grounded attack will stop the player's movement, but is more powerful. Most enemies are 1 hit kill so you go through them when killed but if not you bounce off, pogo'ing used this way)
- Player is rewarded (through full screen anime pictures) for going through chase sections in allotted time AND not getting hit twice
- Dialog is conveyed between a text screen at the bottom with anime portraits
- The girl character conversates with you between levels. You dont have to listen (this affects your ending)
- First half of level is exploratory, latter half is a challenge of execution of what you learned/explored

# Story tones
- Undercurrent of romance (you are there with a girl)
- Heroism

# Story beats
- Each level represents a layer of hell
- But the entire thing is a simulation, their bodies are in some kind of chamber (you find this out in the good ending)
- The enemies are minds that are "too far gone".
- You find a girl who is on the verge of transforming
- Rewards help her (and yourself) regain memories
- You find out that you and her had a child together through these fullscreen cutscenes
- Red undercurrent is a computer deleting data
- You and her (and others) were both tempted in the real world to forget their memories. She does it first, you try to find her, and it leads  to being captured by "something". This thing traps bodies and uses their essence for "soemthing". 

# Controls
- D Pad movement
- Dedicated run/attack button (by default the same, but ALL controls can be remapped)
- Keyboard AND controller support
- an "air dodge" like in melee: you are invulnerable  and if no direction, you maintain momentum. If direction, you go into that direction (8 way) immediately, but no more air dodging and your momentum is cancelled
- Air dodging into the ground allows you to wave dash and act immediately (like Super Smash Brothers Melee)
- Run/attack: attack
- Run button held: run
- down+attack: slide (maintains momentum and slight speed boost, lowers your hitbox so you can slide underthings while running. Does less damage than attack but is still an attack)
- attack in air: attack that makes you hover for a bit. Some cooldown so you cant just hover indefinitely and doesnt completely halt downward movement
- hold attack up/down: hold weapon up or down and allows bouncing (vertical speed at impact should affect bounce height)
- Undecided: do you have to hold down/up to KEEP sword up or down, or just attack? It can be hard on hands to have to hold down/up AND attack AND also hold left or right. Maybe just hold up or down and then you can let go and only stop up or down when ATTACK is released?
- Mario-type physics like: 

## Mario Phsysics
- acceleration when running and jumping. Letting go of run makes you slow to a walk. Letting go of direction on ground makes you slow to a stop. Letting go of direction in air makes you slow, but SLOWER than the rate of decel on ground.
- There should be a max run speed (i.e. the speed of "full run") but CERTAIN things allow you to break that barrier (sliding, speed boost objects, etc). But when past this max full run speed, you should slowly revert back to this speed (unless you get another speed boost or something)
- a "full run" can only be accomplished by running for a few seconds (a la Super Mario Bros 3 on the NES), part of the implicit game loop that's fun should be optimizing for this
- You must hold jump for a bit to reach full jump height.
- Lightly tapping jump => small jump
- Letting go of jump button slows/decelerates vertical movement for a jump
- Turning around midair should be slower than turning around on ground
- Coyote jumping and jump buffering
- In general follow Mario 3 or Super Mario World for guidence.

# Misc stuff I pulled from my notes
Aesthetics:
Sparse
Because I’m lazy
Lots of solid clean lines
Except for main character(s)?
Futuristic / Computer-y

Gameplay:
Tight-ish platforming
Not as “heavy” as mario, but not as insane as super meat boy
Light acceleration that affects jump speed, stopping horizontal movement mid jump, etc
First half of level is SOMEWHAT exploratory
Music-driven last part of level
Have to do things pretty much perfectly, is a reflection of what you’ve learned in the earlier parts of the level;
Intense. Something is chasing your or something

Level ideas:
Moving platforms
Reverse gravity
Low gravity
Bullet hell esque
Ramps
Speed boosts
Levels get “erased” at the end
Bad ending is you start from level 1 as game fades to black.
Meet up in hallway
Analogous to the connections between cells in a CPU or harddrive
Last level has partner in it
Find one “optional” memory in each level
10 levels?

Story beats:
No Memory
Each “level” they regain memories
AS LONG as you get the secret thing in each level
Relationship with other char is “optional”
If you dont spend time, you dont get

# Camera
- The faster you move, the more of the screen is in front of you. Standing still the player is near center. Walking they sit a little behind center. At full run (and anything over it) they sit around the back third of the screen so you see as far ahead as possible.
- Look-ahead distance is driven by actual horizontal speed, not just which way you face. A quick tap backwards or a turnaround at low speed does not swing the camera.
- The camera eases toward the look-ahead target at a capped speed. It never snaps. Reversing at full run swings the view over a short, tunable time.
- Flipping the look-ahead side needs sustained movement the other way (a short time or distance), so dancing back and forth does not shake the screen.
- Vertical: when standing, keep about 2 tiles visible below the player's feet (like SMW). Do not follow the player up during a normal jump. Only move vertically when they land on a new height or leave a vertical window near the top or bottom of the screen. Falling fast past the bottom edge of that window, the camera follows at full speed so the player never leaves the screen.
- Every level has camera limits. Never show outside the level.
- All camera numbers (look-ahead per speed, ease speed, flip hysteresis, vertical window, tiles below feet) are exported so they can be tuned in the editor.
- Undecided: holding up or down while standing still to peek.
- Undecided: whether chase sections shift the view so you can see more of the red current behind you.
