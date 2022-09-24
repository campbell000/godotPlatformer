extends Node

const DOWN_SNAP = Vector2(0, 8)

const GRAVITY = 1000.0

const AIR_ACCEL: float = 530.0


# Constant that slows the player down on the ground when they are moving, but not pressing buttons
const GROUND_DRAG: float = 15.0
const RUN_ACCEL: float = 1550.0
const INITIAL_MAINTAIN_INERTIA_DRAG = 3

# Consttant that slows the player down in teh air when they are moving, but not pressing buttons.
# Less drag than on ground
const AIR_DRAG: float = 2.0;

const MAX_RUN_SPEED: float = 225.0

const MAX_RUN_SPEED_SLOPE: float = 350.0

const NO_SPEED_LIMIT = 42069

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func process_movement(player, delta, options={}):
	#func process_movement(player: KinematicBody2D, delta, xAccel, dragVal=0, gravity=GRAVITY, maxSpeed=NO_SPEED_LIMIT, snap_vector=DOWN_SNAP, stopSmall=false):
	var xAccel = options.get("xAccel", 0)
	var dragVal = options.get("noMovementDrag", 0)
	var gravity = options.get("gravity", GRAVITY)
	var maxSpeed = options.get("maxSpeed", NO_SPEED_LIMIT)
	var snap_vector = options.get("snapVector", DOWN_SNAP)
	var maintainInertiaDrag = options.get("maintainInertiaDrag", 0)
	var stopSmall = options.get("stopSmall", false)
	
	###########################################
	# Horizontal Movement
	###########################################
	player.velocity.x = player.velocity.x + (xAccel * delta)
	if dragVal != 0:
		player.velocity.x = player.velocity.x / (1 + (dragVal * delta))

	if maxSpeed != NO_SPEED_LIMIT:
		if !player.maintainInertia:
			if player.velocity.x > maxSpeed:
				player.velocity.x = maxSpeed
			if player.velocity.x < -maxSpeed:
				player.velocity.x = -maxSpeed
		else:
			#var inertiaDrag = MAINTAIN_INTERTIA_DRAG if !player.isRunningDownHill() else MAINTAIN_INTERTIA_DRAG/1.3
			player.velocity.x = player.velocity.x / (1 + (maintainInertiaDrag * delta))
			
	# Dont allow tiny numbers. Otherwise, the object will keep inching forward
	if stopSmall and player.velocity.x < 2 and player.velocity.x > -2:
		player.velocity.x = 0
			
	###########################################
	# Vertical Movement
	###########################################
	# Apply Gravity to the char's y pos.
	player.velocity.y += gravity * delta
	
	player.velocity = player.move_and_slide_with_snap(player.velocity, snap_vector, Vector2.UP, true)
