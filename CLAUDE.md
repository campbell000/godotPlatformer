# Project
2D platformer in Godot 4 (GDScript). Godot version: 4.7.2, binary at
/Applications/Godot.app/Contents/MacOS/Godot.
Full design: docs/DESIGN.md. Task list: docs/TASKS.md.
Read the relevant section before implementing any gameplay feature.

# Rules
- DESIGN.md is the source of truth. If it's silent or marks something
  as undecided, ask me. Do not invent design decisions.
- If I make a design decision in a session, update DESIGN.md in the same change.
- Use Godot 4 APIs only. Never use Godot 3 syntax. Prefer TileMapLayer over TileMap.
- Base resolution 384x216, integer scaled. Sub-pixel movement is allowed.
- All input goes through InputMap actions. Never hardcode keys or buttons.
- All movement tuning values (speeds, accel, gravity, jump, timers) are
  exported variables in one place so I can tune them in the editor.
  That place is characters/player2/PlayerTuning.gd (a Resource) saved as
  characters/player2/player_tuning.tres. No movement constants anywhere else.
- Physics must be framerate independent.
- New GDScript is snake_case and typed. No print() in physics loops.
- Legacy reference only, read but never edit or import from:
  characters/player/, objects/Physics.gd, characters/player/States/Common.gd,
  levels/DemoLevel.tscn. They get deleted at the end of Milestone 1.
- Do exactly one docs/TASKS.md task per session. If the task line has an
  "Ask first" question, ask it before writing code. Mark the task [~] when
  it is ready for playtest and [x] once I say it is done.

# Layout
- levels/, characters/, objects/, environment/, asset_files/, addons/, docs/

# Verification
- Run the project headless to catch errors (leak warnings at exit are expected):
  /Applications/Godot.app/Contents/MacOS/Godot --headless --path . --quit-after 5
- Run one scene headless:
  /Applications/Godot.app/Contents/MacOS/Godot --headless --path . --quit-after 5 res://levels/TestRoom.tscn
- Parse-check one script:
  /Applications/Godot.app/Contents/MacOS/Godot --headless --path . --check-only -s res://path/to/script.gd
- Grep the output for "SCRIPT ERROR", "ERROR" and "Parse Error".
- Never launch the editor or a windowed game yourself.
- You cannot play the game. Never claim something "feels right."
- End each task with a short list of what I should playtest.
