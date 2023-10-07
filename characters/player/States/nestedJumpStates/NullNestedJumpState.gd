extends NestedState
class_name NullNestedJumpState


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
	player.animatedSprite.play("Fall")
	
# Called ON the first time a state is entered, as well as every physics frame that the state is active
func update(player: Player, parentState: State, delta: float):	
	if Input.is_action_just_pressed('attack') && !Input.is_action_pressed('move_down'):
		if Input.is_action_pressed('move_up'):
			var state = player.get_node("States/UpAirAttack")
			parentState.transitionToNestedState(player, state, delta)
		else:
			var state = player.get_node("States/AirAttack")
			parentState.transitionToNestedState(player, state, delta)
	elif Input.is_action_pressed('move_down') && Input.is_action_pressed('attack'):
			var state = player.get_node("States/DownAirAttack")
			parentState.transitionToNestedState(player, state, delta)
		
func transitionToNewStateIfNecessary(player, nestedState: State, delta):
	pass	
	
func _on_AnimationPlayer_animation_finished(anim):
	pass
	
func end(player: Player, nestedState: State):
	pass
			
func getName():
	return "Nothing"
