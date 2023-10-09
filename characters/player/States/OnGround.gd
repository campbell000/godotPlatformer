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
	if !Input.is_action_pressed("move_left") and !Input.is_action_pressed("move_right"):
		player.animatedSprite.play("Idle")
	if Input.is_action_pressed("move_left") || Input.is_action_pressed("move_right"):
		player.animatedSprite.play("Run")
			
func input_update(player, event):
	# otherwise, if we're jumping (or the user buffered a jump), transition
	if player.justJumpedOrBufferedAJump():
		player.transition_to_state(player.get_node("States/Jumping"))
	elif Input.is_action_just_pressed("attack"):
		if Input.is_action_pressed("move_down"):
			player.transition_to_state(player.get_node("States/GroundSlide"))
		else:
			player.transition_to_state(player.get_node("States/GroundAttack"))
		
			
func physics_update(player, delta):
	Common.handleGroundMovement(player, delta)
	if !player.is_on_floor() && player.state != player.get_node("States/Jumping"):
		var fallingState = player.get_node("States/Falling")
		player.transition_to_state(player.get_node("States/Falling"))
		fallingState.cameFromGround = true


func getName():
	return "OnGround"
