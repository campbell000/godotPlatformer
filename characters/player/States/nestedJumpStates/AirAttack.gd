extends NestedState
class_name AirAttack


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
	self.timeElapsed = 0
	player.animatedSprite.play("AirAttack")
	player.airAttackHitbox.disabled = false;
	
# Called ON the first time a state is entered, as well as every physics frame that the state is active
func update(player: Player, nestedState: State, delta: float):
	self.timeElapsed += delta
	if self.timeElapsed >= ATTACK_START:
		player.airAttackHitbox.disabled = false;
	
	self.transitionToNewStateIfNecessary(player, nestedState, delta)
		
func transitionToNewStateIfNecessary(player, nestedState: State, delta):
	if self.timeElapsed >= ATTACK_DURATION:
		nestedState.transitionToNestedState(player, player.get_node("States/NullNestedJumpState"), delta)
	
func _on_AnimationPlayer_animation_finished(anim):
	pass
	
func end(player: Player, nestedState: State):
	player.airAttackHitbox.disabled = true;
			
func getName():
	return "Air Attack"
