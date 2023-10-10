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
	
func physics_update(player: Player, delta: float):
	self.timeElapsed += delta	
	Common.handleGroundMovement(player, delta, func speedModifier(x):
		x['xAccel'] = 0
		x['drag'] = 10
		return x	
	)

	# If we're not on the floor, and we're not jumping, then we're falling, no matter what
	if !player.is_on_floor() && player.state != player.get_node("States/Jumping"):
		var fallingState = player.get_node("States/Falling")
		player.transition_to_state(player.get_node("States/Falling"))
		fallingState.cameFromGround = true
	else:
		if self.timeElapsed >= ATTACK_DURATION:
			player.transition_to_state(player.get_node("States/OnGround"))
	
func end(player: Player):
	super.end(player)
	player.groundAttackHitbox.disabled = true;

func getName():
	return "Ground Attack"
