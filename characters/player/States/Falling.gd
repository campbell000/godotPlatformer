extends State
class_name Falling

const DOWN_SNAP = Vector2(0, -32)

# Consttant that slows the player down in teh air when they are moving, but not pressing buttons.
# Less drag than on ground
const AIR_DRAG: float = 2.0;

# Rate at which the player gains speed in the air. Slower so that jumps are more committal
const AIR_ACCEL: float = 530.0

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	set_physics_process(false)
	set_process_input(false)

# Called when a state is entered for the first time. Init stuff here
func start(player: Player):
	pass
	
# Called ON the first time a state is entered, as well as every physics frame that the state is active
func update(player: Player, delta: float):
	###########################################
	# Horizontal Movement
	###########################################
	var shouldDrag = !Input.is_action_pressed("move_left") && !Input.is_action_pressed("move_right")
	if shouldDrag:
		player.velocity.x = player.velocity.x / (1 + (AIR_DRAG * delta))
	else:
		var accel = 0
		if Input.is_action_pressed("move_left"):
			accel = -AIR_ACCEL
		elif Input.is_action_pressed("move_right"):
			accel = AIR_ACCEL
			
		player.velocity.x = player.velocity.x + (accel * delta)
		if player.velocity.x > MAX_RUN_SPEED:
			player.velocity.x = MAX_RUN_SPEED
		if player.velocity.x < -MAX_RUN_SPEED:
			player.velocity.x = -MAX_RUN_SPEED
		
	###########################################
	# Vertical Movement
	###########################################
	player.velocity.y += GRAVITY * delta
	
	player.velocity = player.move_and_slide_with_snap(player.velocity, DOWN_SNAP, Vector2.UP)
	
	transitionToNewStateIfNecessary(player, delta)
		
func transitionToNewStateIfNecessary(player, delta):
	if player.is_on_floor():
		var groundState = player.get_node("States/OnGround") as State
		player.transition_to_state(groundState)
	else:
		var wallDragState = player.get_node("States/WallDragging") as State
		if (player.collidedWithLeftWall() && Input.is_action_pressed("move_left")) || (player.collidedWithRightWall() && Input.is_action_pressed("move_right")):
			player.transition_to_state(wallDragState)
			
func getName():
	return "Falling"
