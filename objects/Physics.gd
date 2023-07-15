extends Node

const DOWN_SNAP = Vector2(0, 8)

const GRAVITY = 1000.0

# Constant that slows the player down on the ground when they are moving, but not pressing buttons
const GROUND_DRAG: float = 15.0
const START_RUN_ACCEL: float = 1550.0
const TURN_AROUND_AIR_ACCEL = 800
const TURN_AROUND_GROUND_ACCEL = 1200
const MAINTAIN_RUN_ACCEL = 150.0
const AIR_ACCEL: float = 750.0
const INITIAL_MAINTAIN_INERTIA_DRAG = 1
const GAIN_INERTIA_DRAG = 0.02

# Consttant that slows the player down in teh air when they are moving, but not pressing buttons.
# Less drag than on ground
const AIR_DRAG: float = 2.0;

const MAX_RUN_SPEED: float = 225.0

const MAX_RUN_SPEED_SLOPE: float = 500.0

const NO_SPEED_LIMIT = 42069

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func process_movement(player, delta, options={}):
	var xAccel = options.get("xAccel", 0)
	var dragVal = options.get("noMovementDrag", 0)
	var gravity = options.get("gravity", GRAVITY)
	var maxSpeed = options.get("maxSpeed", NO_SPEED_LIMIT)
	var snap_vector = options.get("snapVector", DOWN_SNAP)
	var maintainInertiaDrag =  options.get("maintainInertiaDrag", 0)
	var stopSmall = options.get("stopSmall", false)
	
	###########################################
	# Horizontal Movement
	###########################################
	player.velocity.x = player.velocity.x + (xAccel * delta)
	if dragVal != 0:
		player.velocity.x = player.velocity.x / (1 + (dragVal * delta))
	
	if player.isGainingInertia:
		player.velocity.x = player.velocity.x / (1 + (GAIN_INERTIA_DRAG * delta))
	elif !player.isGainingInertia and player.isMaintainingInertia:
		var oldV = player.velocity.x
		player.velocity.x = player.velocity.x / (1 + (maintainInertiaDrag * delta))
		
	if maxSpeed != NO_SPEED_LIMIT and !player.isMaintainingInertia:
		if player.velocity.x > maxSpeed:
			player.velocity.x = maxSpeed
		if player.velocity.x < -maxSpeed:
			player.velocity.x = -maxSpeed
			
	# Dont allow tiny numbers. Otherwise, the object will keep inching forward
	if stopSmall and player.velocity.x < 2 and player.velocity.x > -2:
		player.velocity.x = 0
			
	###########################################
	# Vertical Movement
	###########################################
	# Apply Gravity to the char's y pos.
	player.velocity.y += gravity * delta
	
	player.set_velocity(player.velocity)
	# TODOConverter40 looks that snap in Godot 4.0 is float, not vector like in Godot 3 - previous value `snap_vector`
	player.set_up_direction(Vector2.UP)
	player.floor_snap_length = 8
	player.set_floor_stop_on_slope_enabled(true)
	player.move_and_slide()
	player.velocity = player.velocity
	
# TODO: Better, faster way to do this?
const INVALID_WALL_JUMP_CELLS = {
	18: [41]
}
