# Tasks

One task per Claude Code session. `[ ]` not started, `[~]` built and awaiting
playtest, `[x]` playtested and committed. "Ask first" is a design question to
settle with me before any code for that task is written; the answer goes into
DESIGN.md in the same change. "Adds" lists the PlayerTuning exports the task
introduces. Starting values come from the legacy constants in
objects/Physics.gd and characters/player/States/Common.gd where one exists.

## Milestone 1: player controller in a grey-box room

New player lives in characters/player2/ until M1-22 renames it. Test room is
levels/TestRoom.tscn and becomes the main scene in M1-01. Order follows the
"Mario Phsysics" section of DESIGN.md, then "Controls".

- [ ] M1-01 Grey-box room, Player2 skeleton (CharacterBody2D, PlayerTuning resource, PlayerState base, state machine node), Idle and Walk states, input read once per tick into plain fields, DebugHud showing state/vx/vy/fps, InputMap already has run. No gravity yet. Playtest: walk and stop on keyboard and pad, no drift at rest, last-pressed direction wins. Adds: walk_speed, walk_accel, ground_decel, ground_turn_accel.
- [ ] M1-02 Gravity, Fall state, terminal velocity, KillPlane that respawns at Spawn, a ledge in the room. Playtest: walk off ledge, clean landing, no snags on tile seams. Adds: gravity, max_fall_speed.
- [ ] M1-03 Fixed-height jump, staircase and gaps added to the room. Playtest: which step heights clear. Adds: jump_velocity.
- [ ] M1-04 Variable jump: hold for full height, release cuts it, minimum jump. Playtest: tap vs hold difference, release feels like a cut not a stop. Adds: jump_release_gravity_mult, jump_hold_gravity_mult, jump_min_hold_time.
- [ ] M1-05 Air control: air accel and decel separate from ground, air turnaround slower than ground. Playtest: drift further in air than on ground, reversal in air is sluggish but possible. Adds: air_accel, air_decel, air_turn_accel.
- [ ] M1-06 Coyote time and jump buffer. Playtest: late jump off a ledge still works, pressing slightly before landing jumps on contact. Adds: coyote_time, jump_buffer_time.
- [ ] M1-07 Run button and Run state, releasing run decays to walk speed. Ask first: run and attack share a key by default, confirm hold = run and tap = attack, and what the hold threshold is. Playtest: walk/run transitions on keyboard and pad. Adds: run_speed, run_accel, run_to_walk_decel.
- [ ] M1-08 Full-run buildup meter (SMB3 P-meter style): charge while at run speed for a few seconds, unlock full_run_speed, decay when slower, survive short jumps, shown on DebugHud. Playtest: how long the charge should take, whether a small jump drops the meter. Adds: full_run_speed, full_run_charge_time, full_run_meter_decay.
- [ ] M1-09 Jump height scales with horizontal speed. Playtest: full-run jump clears a higher step than a walk jump. Adds: jump_speed_bonus.
- [ ] M1-10 Speed cap and overspeed decay, boost pad in the room. Ask first: does holding run slow the decay back to the cap, and does overspeed survive a jump. Playtest: hit the pad, feel the slow revert to the cap. Adds: overspeed_decay_ground, overspeed_decay_air.
- [ ] M1-11 Slopes: slope tiles in the room, floor snap, downhill speed gain within the cap rules. Playtest: run up and down ramps without launching or stalling. Adds: slope_speed_gain, floor_snap_length.
- [ ] M1-12 Wall slide. Playtest: slide down the tall wall, let go of the wall direction to drop. Adds: wall_slide_speed, wall_slide_accel.
- [ ] M1-13 Wall jump with a brief input lock. Playtest: climb the 3-tile shaft, jump away cleanly, no re-sticking. Adds: wall_jump_velocity, wall_jump_lock_time.
- [ ] M1-14 Slide (down + attack on the ground): speed boost, low collision shape, cannot stand up under a ceiling, slide-jump. Playtest: slide through the 1-tile tunnel at walk speed vs full run. Adds: slide_boost, slide_min_time, slide_decel, slide_jump_velocity.
- [ ] M1-15 Air dodge: invulnerable, no direction keeps momentum, 8-way direction cancels momentum, once per airtime. Playtest: neutral vs directional dodge, cannot dodge twice, resets on landing. Adds: air_dodge_speed, air_dodge_duration, air_dodge_momentum_keep.
- [ ] M1-16 Wavedash: air dodge into the ground within a window lands with horizontal speed and immediate control. Ask first: may a wavedash exceed full-run speed, and if so does it follow the overspeed decay rule. Playtest: dodge diagonally into the floor, act instantly after. Adds: wavedash_window, wavedash_speed_retain, wavedash_friction.
- [ ] M1-17 Air attack with hover and cooldown, hitbox placeholder, no damage yet. Playtest: chained attempts, cooldown stops infinite hover, partial stall not a full stop. Adds: air_attack_hover_time, air_attack_gravity_scale, air_attack_cooldown, air_attack_fall_cap.
- [ ] M1-18 Sword held down and pogo on a bounce block, bounce scaled by impact speed. Ask first: the DESIGN.md "Undecided" question, must down stay held or does attack + down latch until attack is released. Playtest: fast fall bounces higher than slow, chain bounces. Adds: pogo_min_bounce, pogo_impact_multiplier.
- [ ] M1-19 Sword held up. Ask first: what an upward hit does (bounce down off things above, or attack only). Playtest: hold up in the air. Adds: up_attack_duration.
- [ ] M1-20 Grounded attack with hard stop. Ask first: does a tap while running hard-stop the player, and can jump cancel it. Playtest: attack from full run and from idle. Adds: ground_attack_duration, ground_attack_stop_decel.
- [ ] M1-21 Hurt state with knockback, invulnerability frames with blink, a spike tile in the room. Ask first: how many hits the player can take, and whether a hit resets the run meter. Playtest: knockback direction, blink duration. Adds: hurt_knockback, hurt_lock_time, invuln_time.
- [ ] M1-22 Delete the legacy player, remove the Physics and Common autoloads, rename characters/player2 to characters/player, swap DemoLevel's player for the new one. Playtest: DemoLevel runs with the new player. Adds: none.

## Later milestones (expanded into tasks when Milestone 1 is done)

- M2 Combat and enemies: hitbox and hurtbox framework, port Floopy, Ghost and Turret, player health. Ask first: the health system.
- M3 Camera: speed-driven look-ahead and vertical follow rules per the Camera section of DESIGN.md, level limits. Legacy reference: objects/Camera.gd (direction-based four-line offset).
- M4 Level objects: moving platforms, boost pads, gravity triggers, MemoryChip, checkpoints.
- M5 Dialog and cutscenes: port DialogBubbles, Cutscene state, between-level conversations.
- M6 Chase and DeleteRay: timed race, music switch, hit counter, reward picture. Ask first: how chase obstacles stay readable at speed, allotted time per level.
- M7 Level 1.
- M8 Presentation: art, audio, menus, input remapping UI, saves.
- M9 Endings and the 10-level scaffold. Ask first: how listening to the girl, optional memories and chase rewards combine into the ending.
