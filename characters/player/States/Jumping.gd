extends State
class_name Jumping

# Gravity when the player is holding the JUMP button
const JUMP_GRAVITY: float = 300.0

# Initial velocity of the player's jump
const JUMP_FORCE: float = 215.0

const DOWN_SNAP = Vector2(0, -32)

# Once the player's vel is at or over this limit (i.e. towards the apex of their jump), regular GRAVITY gets applied
# Primarily used so that the jump isn't as floaty looking. Also, increase this value so that the player needs to
# hold down the jump button for less time (annoying to have to hold down the button for the ENTIRE duration of the jump)
const JUMP_VEL_LIMIT = -120.0

var isHighJumping = true
var firstUpdate = false

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	set_physics_process(false)
	set_process_input(false)

func start(player: Player):
	self.isHighJumping = true
	player.bufferTimer = 0
	player.velocity.y = -JUMP_FORCE
	self.firstUpdate = true
	
func update(player: Player, delta: float):
	# If the user is holding down the jump button, then do a high jump for this frame.
	# If they aren't, then don't allow a high jump for the rest of the jump, even if the
	# user holds down jump again
	var currentGrav = Physics.GRAVITY
	if self.isHighJumping:
		if !Input.is_action_pressed("jump"):
			self.isHighJumping = false
			
	# If we ARE high high jumping, apply a lesser gravity to the player
	if self.isHighJumping and player.velocity.y < JUMP_VEL_LIMIT:
		currentGrav = JUMP_GRAVITY

	# Stop high jumping at a certain point, no matter what. Makes it so the user doesn't need to hold
	# jump for the entirety of the jump (which would be annoying)
	if player.velocity.y >= JUMP_VEL_LIMIT:
		self.isHighJumping = false
	
	var accel = 0
	if player.getDeconflictedDirectionalInput() == "move_left":
		if player.velocity.x <= -Physics.MAX_RUN_SPEED:
			accel = -Physics.RUN_ACCEL
		else:
			accel = -Physics.AIR_ACCEL
			
	elif player.getDeconflictedDirectionalInput() == "move_right":
		if player.velocity.x >= Physics.MAX_RUN_SPEED:
			accel = Physics.RUN_ACCEL
		else:
			accel = Physics.AIR_ACCEL
	
	# Snap vector must be zero on the first frame to allow the jump to happen at all
	var snapVector = Vector2.ZERO if self.firstUpdate else Physics.DOWN_SNAP
	
	var dragVal = Physics.AIR_DRAG if accel == 0 else 0
	
	var maxRunSpeed = Physics.MAX_RUN_SPEED
	
	Physics.process_air_movement(player, delta, accel, dragVal, currentGrav, maxRunSpeed, snapVector)
	
	if player.velocity.y >= 0:
		player.animatedSprite.play("Fall")
	
	self.transitionToNewStateIfNecessary(player, delta)
	self.firstUpdate = false

func transitionToNewStateIfNecessary(player, delta):
	# If on the floor, then transition to ground
	if player.is_on_floor():
		var groundState = player.get_node("States/OnGround") as State
		player.transition_to_state(groundState)
	else:
		# Otherwise, if we're not on the first frame (otherwise, holding jump and direction against a wall on the ground
		# causes an immediate wall jump), and the user (buffered a) jump and they're against a wall, do the wall jump immediately
		var goToWallDrag = false
		if !self.firstUpdate && player.justJumpedOrBufferedAJump() && (player.collidedWithLeftWall() || player.collidedWithRightWall()):
			player.transition_to_state(player.get_node("States/WallJumping"))
		elif player.velocity.y >= 0 && (player.collidedWithLeftWall() && Input.is_action_pressed("move_left") || player.collidedWithRightWall() && Input.is_action_pressed("move_right")):
			# Otherwise, if they've stopped ascending and holding input against a wall, start the wall drag
			var wallDraggingState = player.get_node("States/WallDragging")
			player.transition_to_state(wallDraggingState)	

func end(player):
	self.isHighJumping = false
	
func getName():
	return "Jumping"
