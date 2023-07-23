extends State
class_name OnGround

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	set_physics_process(false)
	set_process_input(false)

# Called when a state is entered for the first time. Init stuff here
func start(player: Player):
	pass
	
func update(player: Player, delta: float):
	# Handle run/idle animations
	if Input.is_action_pressed("move_left") || Input.is_action_pressed("move_right"):
		player.animatedSprite.play("Run")
	elif !Input.is_action_pressed("move_left") and !Input.is_action_pressed("move_right"):
		player.animatedSprite.play("Idle")
	
	# Put into common because it's shared with GroundAttack
	Common.handleGroundMovement(player, delta)
	
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
		elif Input.is_action_pressed("attack"):
			var groundAttack = player.get_node("States/GroundAttack");
			player.transition_to_state(player.get_node("States/GroundAttack"))

func getName():
	return "OnGround"
