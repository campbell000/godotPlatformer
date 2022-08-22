extends Node
class_name State


# Variables that are used by multiple states
const GRAVITY = 1000.0
const MAX_RUN_SPEED: float = 225.0
const WALL_JUMP_FORCE = Vector2(225, -300)


# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	set_physics_process(false)
	set_process_input(false)

# Called when a state is entered for the first time. Init stuff here
func start(player):
	pass
	
# Called during every update
func update(player, delta):
	pass
	
# Called during every update, AFTER the update() method and after a character has moved
func update_after_move(player, delta):
	pass
	
# Called when the state is being exited for a new state. Do cleanup if necessary
func end(player):
	pass
	
func getName():
	pass
