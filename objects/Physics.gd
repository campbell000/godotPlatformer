extends Node


const DOWN_SNAP = Vector2(0, 32)

const GRAVITY = 1000.0

const MAX_RUN_SPEED: float = 225.0

const AIR_ACCEL: float = 530.0

# Constant that slows the player down on the ground when they are moving, but not pressing buttons
const GROUND_DRAG: float = 10.0

# Consttant that slows the player down in teh air when they are moving, but not pressing buttons.
# Less drag than on ground
const AIR_DRAG: float = 2.0;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func process_air_movement(player: KinematicBody2D, delta, xAccel, shouldDrag=false, gravity=GRAVITY, limitXSpeed=true, snap_vector=DOWN_SNAP):
	###########################################
	# Horizontal Movement
	###########################################
	player.velocity.x = player.velocity.x + (xAccel * delta)
	
	if shouldDrag:
		player.velocity.x = player.velocity.x / (1 + (AIR_DRAG * delta))
		
	# But limit their max speed
	if limitXSpeed:
		if player.velocity.x > MAX_RUN_SPEED:
			player.velocity.x = MAX_RUN_SPEED
		if player.velocity.x < -MAX_RUN_SPEED:
			player.velocity.x = -MAX_RUN_SPEED
			
	###########################################
	# Vertical Movement
	###########################################
	# Apply Gravity to the char's y pos.
	player.velocity.y += gravity * delta
	
	# Move the player and set their new velocity based on their current velocity, collisions, etc
	player.velocity = player.move_and_slide_with_snap(player.velocity, snap_vector, Vector2.UP, true)

func process_ground_movement(player: KinematicBody2D, delta, xAccel, shouldDrag=false, gravity=GRAVITY, limitXSpeed=true):
	###########################################
	# Horizontal Movement
	###########################################
	player.velocity.x = player.velocity.x + (xAccel * delta)
	if shouldDrag:
		player.velocity.x = player.velocity.x / (1 + (GROUND_DRAG * delta))
		
		
	# Don't let their ground speed exceed a maximum
	if limitXSpeed:
		if player.velocity.x > MAX_RUN_SPEED:
			player.velocity.x = MAX_RUN_SPEED
		if player.velocity.x < -MAX_RUN_SPEED:
			player.velocity.x = -MAX_RUN_SPEED
		
	# Dont allow tiny numbers. Otherwise, the user will keep inching forward
	if player.velocity.x < 10 and player.velocity.x > -10:
		player.velocity.x = 0

	player.velocity.y += gravity * delta
	player.velocity = player.move_and_slide_with_snap(player.velocity, DOWN_SNAP, Vector2.UP, true)
