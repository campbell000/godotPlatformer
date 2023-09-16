extends NestedState
class_name NullNestedState


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var timeElapsed = 0
var ATTACK_DURATION = 0.4
var ATTACK_START = 0.03333


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called when a state is entered for the first time. Init stuff here
func start(player: Player, nestedState: State):
	pass
	
# Called ON the first time a state is entered, as well as every physics frame that the state is active
func update(player: Player, nestedState: State, delta: float):	
	pass
		
func transitionToNewStateIfNecessary(player, nestedState: State, delta):
	pass	
	
func _on_AnimationPlayer_animation_finished(anim):
	pass
	
func end(player: Player, nestedState: State):
	pass
			
func getName():
	return "NULL NESTED"
