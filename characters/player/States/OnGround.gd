extends State
class_name OnGround

const DOWN_SNAP = Vector2(0, -32)

# Max speed the player can be moving due to simply running (TODO: factor in things that affect speed)
const MAX_RUN_SPEED: float = 200.0

# Rate at which the player gains speed
const RUN_ACCEL: float = 1000.0

# Constant that slows the player down on the ground when they are moving, but not pressing buttons
const GROUND_DRAG: float = 10.0

# Initial velocity of the player's jump
const JUMP_FORCE: float = 215.0

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	set_physics_process(false)
	set_process_input(false)

# Called when a state is entered for the first time. Init stuff here
func start(player: Player):
	player.snapVector = Vector2.DOWN
	pass
	
# Called ON the first time a state is entered, as well as every physics frame that the state is active
func update(player: Player, delta: float):
	###########################################
	# Horizontal Movement
	###########################################
	# If the user is pressing left or right, have the player start running
	if Input.is_action_pressed("move_left"):
		player.velocity.x = player.velocity.x - (RUN_ACCEL * delta)
	elif Input.is_action_pressed("move_right"):
		player.velocity.x = player.velocity.x + (RUN_ACCEL * delta)
	else:
		player.velocity.x = player.velocity.x / (1 + (GROUND_DRAG * delta))
		
	# Don't let their ground speed exceed a maximum
	if player.velocity.x > MAX_RUN_SPEED:
		player.velocity.x = MAX_RUN_SPEED
	if player.velocity.x < -MAX_RUN_SPEED:
		player.velocity.x = -MAX_RUN_SPEED
		
	# Dont allow tiny numbers. Otherwise, the user will keep inching forward
	if player.velocity.x < 10 and player.velocity.x > -10:
		player.velocity.x = 0
		

	###########################################
	# Vertical Movement
	###########################################
	# If the jump button was just pressed OR the user buffered a jump, transition to the Jumping state.
	# Make sure the run logic AND the jump logic both execute
	var doJump = false
	if (Input.is_action_just_pressed("jump") || player.bufferTimer > 0) and player.canJump:
		var jumpState = player.get_node("States/Jumping") as State
		player.transition_to_state(jumpState)
		doJump = true
	
	# If we didnt JUST jump, have gravity apply its force on the player's y pos
	if !doJump:
		player.velocity.y += GRAVITY * delta


func update_after_move(player, delta):
	var isMoving = false
	if abs(player.velocity.x) > 1:
		player.animatedSprite.play("Run")
	else:
		player.animatedSprite.play("Idle")
