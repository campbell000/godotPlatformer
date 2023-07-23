extends Node

const DOWN_SNAP = Vector2(0, 8)

const GRAVITY = 1000.0

# Constant that slows the player down on the ground when they are moving, but not pressing buttons
const GROUND_DRAG: float = 10.0
const START_RUN_ACCEL: float = 1550.0
const TURN_AROUND_AIR_ACCEL = 800
const TURN_AROUND_GROUND_ACCEL = 1200
const MAINTAIN_RUN_ACCEL = 150.0
const AIR_ACCEL: float = 750.0
const GAIN_INERTIA_DRAG = 0.3
const BREAKING_SPEED_DRAG = 1.15
const AIR_BREAKING_SPEED_DRAG = 0.5

# Consttant that slows the player down in teh air when they are moving, but not pressing buttons.
# Less drag than on ground
const AIR_DRAG: float = 2.0;

const MAX_RUN_SPEED: float = 225.0

const MAX_RUN_SPEED_SLOPE: float = 500.0

var aaa =null

# Called when the node enters the scene tree for the first time.
func _ready():
	self.aaa = null
	pass # Replace with function body.
	
func process_movement(player, delta, options={}):
	var xAccel = options.get("xAccel", 0)
	var dragVal = options.get("drag", 0)
	var gravity = options.get("gravity", GRAVITY)
	var maxSpeed = options.get("maxSpeed")
	var stopSmall = options.get("stopSmall", false)
	
	###########################################
	# Horizontal Movement
	###########################################
	player.velocity.x = player.velocity.x + (xAccel * delta)
	if dragVal != 0:
		player.velocity.x = player.velocity.x / (1 + (dragVal * delta))
		
	if !player.isBreakingSpeedLimit:
		if player.velocity.x > maxSpeed:
			player.velocity.x = maxSpeed
		if player.velocity.x < -maxSpeed:
			player.velocity.x = -maxSpeed
	
	# If on a slope, then modify speed based on slope
	var floor_normal = player.get_floor_normal()
	if floor_normal.x != 0:
		player.velocity.x = player.velocity.x + (floor_normal.x * 10) 
	
	# Dont allow tiny numbers. Otherwise, the object will keep inching forward
	if stopSmall and player.velocity.x < 2 and player.velocity.x > -2:
		player.velocity.x = 0
	
	###########################################
	# Vertical Movement
	###########################################
	# Apply Gravity to the char's y pos.
	player.velocity.y += gravity * delta
	player.move_and_slide()
