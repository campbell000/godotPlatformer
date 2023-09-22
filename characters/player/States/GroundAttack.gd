extends State
class_name GroundAttack


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var timeElapsed = 0

var ATTACK_DURATION = 0.4


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called when a state is entered for the first time. Init stuff here
func start(player: Player):
	self.timeElapsed = 0
	player.animatedSprite.play("GroundAttack")
	player.groundAttackHitbox.disabled = false;
	
# Called ON the first time a state is entered, as well as every physics frame that the state is active
func update(player: Player, delta: float):
	Common.handleGroundMovement(player, delta, func speedModifier(x):
		x['xAccel'] = 0
		x['drag'] = 3
		return x	
	)
	
	self.timeElapsed += delta	
	self.transitionToNewStateIfNecessary(player, delta)

		
func transitionToNewStateIfNecessary(player, delta):
	# If we're not on the floor, and we're not jumping, then we're falling, no matter what
	if !player.is_on_floor() && player.state != player.get_node("States/Jumping"):
		var fallingState = player.get_node("States/Falling")
		player.transition_to_state(player.get_node("States/Falling"))
		fallingState.cameFromGround = true
	else:
		# otherwise, if we're jumping (or the user buffered a jump), transition
		if player.justJumpedOrBufferedAJump():
			player.transition_to_state(player.get_node("States/Jumping"))
	if self.timeElapsed >= ATTACK_DURATION:
		player.transition_to_state(player.get_node("States/OnGround"))
	
func _on_AnimationPlayer_animation_finished(anim):
	pass

func end(player: Player):
	player.groundAttackHitbox.disabled = true;

func getName():
	return "Ground Attack"
