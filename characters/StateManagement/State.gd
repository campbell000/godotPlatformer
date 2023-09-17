extends Node2D
class_name State

var currentInnerState: NestedState;

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	set_physics_process(false)
	set_process_input(false)

# Called when a state is entered for the first time. Init stuff here
func start(player):
	pass
	
func transitionToNestedState(player: Player, newInnerStateObj: NestedState, delta: float):
	if (self.currentInnerState != null):
		self.currentInnerState.end(player, self)
	
	var newInnerState: NestedState = newInnerStateObj as NestedState
	self.currentInnerState = newInnerState
	newInnerState.start(player, self)

# Called during every update
func update(player, delta):
	pass
	
# Called when the state is being exited for a new state. Do cleanup if necessary
func end(player):
	pass
	
func getName():
	pass
