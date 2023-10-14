extends Node
class_name NestedState

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called when a state is entered for the first time. Init stuff here
func start(player, parentState: State):
	pass
	
# Called during every update
func process_update(player, parentState: State, delta):
	pass
	
# Called during every _process update
func physics_update(player, parentState: State, delta):
	pass
	
# Called when the state is being exited for a new state. Do cleanup if necessary
func end(player, parentState: State):
	pass
	
func getName():
	pass
