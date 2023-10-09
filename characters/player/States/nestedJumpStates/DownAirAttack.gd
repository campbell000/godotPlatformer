extends NestedState
class_name DownAirAttack


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var timeElapsed = 0
var ATTACK_DURATION = 1
var ATTACK_START = 0.03333


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called when a state is entered for the first time. Init stuff here
func start(player: Player, nestedState: State):
	self.timeElapsed = 0
	player.animatedSprite.play("DownAirAttack")
	player.downairInteractiveCollisionShape.disabled = false
	player.downairHitbox.disabled = false
	player.interactiveCollisionShape.disabled = true
	
# Called ON the first time a state is entered, as well as every physics frame that the state is active
func update(player: Player, nestedState: State, delta: float):
	self.timeElapsed += delta
	self.transitionToNewStateIfNecessary(player, nestedState, delta)
		
func transitionToNewStateIfNecessary(player, nestedState: State, delta):
	if Input.is_action_just_released("attack"):
		nestedState.transitionToNestedState(player, player.get_node("States/NullNestedJumpState"), delta)
	
func _on_AnimationPlayer_animation_finished(anim):
	pass
	
func end(player: Player, nestedState: State):
	player.downairInteractiveCollisionShape.disabled = true
	player.downairHitbox.disabled = true
	player.interactiveCollisionShape.disabled = false
			
func getName():
	return "Air Attack"
