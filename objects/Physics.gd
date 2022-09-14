extends Node


const DOWN_SNAP = Vector2(0, 8)

const GRAVITY = 1000.0

const AIR_ACCEL: float = 530.0

# Constant that slows the player down on the ground when they are moving, but not pressing buttons
const GROUND_DRAG: float = 15.0

const MAINTAIN_INTERTIA_DRAG = 3.65
const AIR_MAINTAIN_INTERTIA_DRAG = 3.65

# Consttant that slows the player down in teh air when they are moving, but not pressing buttons.
# Less drag than on ground
const AIR_DRAG: float = 2.0;

const MAX_RUN_SPEED: float = 225.0

const MAX_RUN_SPEED_SLOPE: float = 350.0

const NO_SPEED_LIMIT = 42069

const RUN_ACCEL: float = 1000.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func process_air_movement(player: KinematicBody2D, delta, xAccel, dragVal=0, gravity=GRAVITY, maxSpeed=NO_SPEED_LIMIT, snap_vector=DOWN_SNAP):
	self.process_movement(player, delta, xAccel, dragVal, gravity, maxSpeed, snap_vector, false)

func process_ground_movement(player: KinematicBody2D, delta, xAccel, dragVal=0, gravity=GRAVITY, maxSpeed=NO_SPEED_LIMIT, snap_vector=DOWN_SNAP):
	self.process_movement(player, delta, xAccel, dragVal, gravity, maxSpeed, snap_vector, true)
	
func process_movement(player: KinematicBody2D, delta, xAccel, dragVal=0, gravity=GRAVITY, maxSpeed=NO_SPEED_LIMIT, snap_vector=DOWN_SNAP, stopSmall=false):
	###########################################
	# Horizontal Movement
	###########################################
	var oldVel = player.velocity.x
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
			var inertiaDrag = MAINTAIN_INTERTIA_DRAG if !player.is_on_floor() else MAINTAIN_INTERTIA_DRAG
			player.velocity.x = player.velocity.x / (1 + (inertiaDrag * delta))
			
	# Dont allow tiny numbers. Otherwise, the object will keep inching forward
	if stopSmall and player.velocity.x < 2 and player.velocity.x > -2:
		player.velocity.x = 0
			
	###########################################
	# Vertical Movement
	###########################################
	# Apply Gravity to the char's y pos.
	player.velocity.y += gravity * delta
	
	player.velocity = player.move_and_slide_with_snap(player.velocity, snap_vector, Vector2.UP, true)
	#var a = Vector2(0, player.velocity.y)
	#player.velocity.y = player.move_and_slide_with_snap(a, snap_vector, Vector2.UP, true).y
	#var b = Vector2(player.velocity.x, 0)
	#player.velocity.x = player.move_and_slide_with_snap(b, snap_vector, Vector2.UP, true).x
