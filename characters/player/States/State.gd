extends Node
class_name State


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	set_physics_process(false)
	set_process_input(false)

# Called when a state is entered for the first time. Init stuff here
func start(player: Player):
	pass
	
# Called ON the first time a state is entered, as well as every physics frame that the state is active
func update(player: Player):
	pass
	
# Called when transitioning to a new state. Use to clean stuff up in this state if necessary
func transition_to(player: Player, stateName: String):
	pass
