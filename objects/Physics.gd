extends Node


const DOWN_SNAP = Vector2(0, 32)

const GRAVITY = 1000.0

const AIR_ACCEL: float = 530.0

# Constant that slows the player down on the ground when they are moving, but not pressing buttons
const GROUND_DRAG: float = 15.0

const MAINTAIN_INTERTIA_DRAG = 4

# Consttant that slows the player down in teh air when they are moving, but not pressing buttons.
# Less drag than on ground
const AIR_DRAG: float = 2.0;

const MAX_RUN_SPEED: float = 225.0

const MAX_RUN_SPEED_SLOPE: float = 300.0

const NO_SPEED_LIMIT = 9999999999

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func process_air_movement(player: KinematicBody2D, delta, xAccel, dragVal=0, gravity=GRAVITY, maxSpeed=NO_SPEED_LIMIT, snap_vector=DOWN_SNAP):
	###########################################
	# Horizontal Movement
	###########################################
	var oldVel = player.velocity.x
	player.velocity.x = player.velocity.x + (xAccel * delta)
	
	if dragVal != 0:
		player.velocity.x = player.velocity.x / (1 + (dragVal * delta))
		
	# But limit their max speed
	if maxSpeed != NO_SPEED_LIMIT:
		if player.velocity.x > maxSpeed:
			player.velocity.x = maxSpeed
		if player.velocity.x < -maxSpeed:
			player.velocity.x = -maxSpeed
			
	###########################################
	# Vertical Movement
	###########################################
	# Apply Gravity to the char's y pos.
	player.velocity.y += gravity * delta
	
	# Move the player and set their new velocity based on their current velocity, collisions, etc
	player.velocity = player.move_and_slide_with_snap(player.velocity, snap_vector, Vector2.UP, true)

func process_ground_movement(player: KinematicBody2D, delta, xAccel, dragVal=0, gravity=GRAVITY, maxSpeed=NO_SPEED_LIMIT, snap_vector=DOWN_SNAP, maintainIntertia=false):
	###########################################
	# Horizontal Movement
	###########################################
	player.velocity.x = player.velocity.x + (xAccel * delta)
	if dragVal != 0:
		player.velocity.x = player.velocity.x / (1 + (GROUND_DRAG * delta))

	# But limit their max speed
	#NEED TO DETECT IF THEYRE GOING DOWNHILL CANT JUST APPLY THIS ON SLOPE
	if maxSpeed != NO_SPEED_LIMIT:
		if !maintainIntertia:
			if player.velocity.x > maxSpeed:
				player.velocity.x = maxSpeed
			if player.velocity.x < -maxSpeed:
				player.velocity.x = -maxSpeed
		elif player.velocity.x > maxSpeed or player.velocity.x < -maxSpeed:
			player.velocity.x = player.velocity.x / (1 + (MAINTAIN_INTERTIA_DRAG * delta))
		
	# Dont allow tiny numbers. Otherwise, the object will keep inching forward
	if player.velocity.x < 2 and player.velocity.x > -2:
		player.velocity.x = 0

	player.velocity.y += gravity * delta
	player.velocity = player.move_and_slide_with_snap(player.velocity, snap_vector, Vector2.UP, false)
