# Project
2D platformer in Godot 4 (GDScript). Full design: docs/DESIGN.md.
Read the relevant section before implementing any gameplay feature.

# Rules
- DESIGN.md is the source of truth. If it's silent or marks something
  as undecided, ask me. Do not invent design decisions.
- If I make a design decision in a session, update DESIGN.md in the same change.
- Base resolution 384x216, integer scaled. Sub-pixel movement is allowed.
- All input goes through InputMap actions. Never hardcode keys or buttons.
- All movement tuning values (speeds, accel, gravity, jump, timers) are
  exported variables in one place so I can tune them in the editor.
- Physics must be framerate independent.

# Layout
- scenes/, scripts/, assets/, docs/

# Verification
- You cannot play the game. Never claim something "feels right."
- End each task with a short list of what I should playtest.
