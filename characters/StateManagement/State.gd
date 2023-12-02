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
		print(self.currentInnerState.getName()+" => "+newInnerStateObj.getName())
	else:
		print("NOTHING => "+newInnerStateObj.getName())
	
	var newInnerState: NestedState = newInnerStateObj as NestedState
	self.currentInnerState = newInnerState
	newInnerState.start(player, self)

# Called during every _process update
func process_update(player, delta):
	pass
	
# Called during every _physics_process update
func physics_update(player, delta):
	pass
	
# Called when the state is being exited for a new state. Do cleanup if necessary
func end(player):
	if (self.currentInnerState != null):
		self.currentInnerState.end(player, self)
	
func getName():
	pass
