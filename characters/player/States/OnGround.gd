extends State
class_name OnGround

const DOWN_SNAP = Vector2(0, -32)

# Rate at which the player gains speed
const RUN_ACCEL: float = 1000.0

# Constant that slows the player down on the ground when they are moving, but not pressing buttons
const GROUND_DRAG: float = 10.0

# Initial velocity of the player's jump
const JUMP_FORCE: float = 205.0

var currPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	set_physics_process(false)
	set_process_input(false)

# Called when a state is entered for the first time. Init stuff here
func start(player: Player):
	self.currPlayer = player
	player.snapVector = Vector2.DOWN
	pass
	
# Called ON the first time a state is entered, as well as every physics frame that the state is active
func update(player: Player, delta: float):
	##################################
	# State Management
	###################################
	var newState = false
	if !player.is_on_floor():
		var jumpState = player.get_node("States/Jumping") as State
		if player.state != jumpState:
			var fallingState = player.get_node("States/Falling") as State
			player.velocity.y += GRAVITY * delta
			player.transition_to_state(fallingState)
	else:
		if (Input.is_action_just_pressed("jump") || player.bufferTimer > 0) and player.canJump:
			if !Input.is_action_just_pressed("jump") && player.bufferTimer > 0:
				print("BUFFERED JUMP!")
				player.bufferTimer = 0
			var jumpState = player.get_node("States/Jumping") as State
			player.snapVector = Vector2.ZERO
			player.velocity.y = -JUMP_FORCE
			player.transition_to_state(jumpState)

	if player.state == player.get_node("States/OnGround"):
		if abs(player.velocity.x) > 1:
			player.animatedSprite.play("Run")
		else:
			player.animatedSprite.play("Idle")
	
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

		# If we didnt JUST jump, have gravity apply its force on the player's y pos
		player.velocity.y += GRAVITY * delta

func getName():
	return "OnGround"
