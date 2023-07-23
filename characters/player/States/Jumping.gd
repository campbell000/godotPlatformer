extends State
class_name Jumping

# Gravity when the player is holding the JUMP button
const JUMP_GRAVITY: float = 300.0

const CANCELLED_JUMP_GRAVITY: float = 1325.0

# Initial velocity of the player's jump
const JUMP_FORCE: float = 215.0

const DOWN_SNAP = Vector2(0, -32)

# Once the player's vel is at or over this limit (i.e. towards the apex of their jump), regular GRAVITY gets applied
# Primarily used so that the jump isn't as floaty looking. Also, increase this value so that the player needs to
# hold down the jump button for less time (annoying to have to hold down the button for the ENTIRE duration of the jump)
const JUMP_VEL_LIMIT = -120.0

var isHighJumping = true
var firstUpdate = false
var canceledEarly = false

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	set_physics_process(false)
	set_process_input(false)

func start(player: Player):
	# Set correct states
	self.isHighJumping = true
	player.storedWallJumpSpeed = 0
	player.bufferTimer = 0
	player.velocity.y = -JUMP_FORCE
	self.firstUpdate = true
	
	# play animations
	player.animatedSprite.play("Jump")
	
func update(player: Player, delta: float):
	# If the user is holding down the jump button, then do a high jump for this frame.
	# If they aren't, then don't allow a high jump for the rest of the jump, even if the
	# user holds down jump again
	if absf(player.velocity.x) > absf(Physics.MAX_RUN_SPEED):
		player.storedWallJumpSpeed = player.velocity.x
	var currentGrav = Physics.GRAVITY
	if self.isHighJumping:
		if !Input.is_action_pressed("jump"):
			self.isHighJumping = false
			if player.velocity.y < JUMP_VEL_LIMIT:
				self.canceledEarly = true
			
	# Stop high jumping at a certain point, no matter what. Makes it so the user doesn't need to hold
	# jump for the entirety of the jump (which would be annoying)
	if player.velocity.y >= JUMP_VEL_LIMIT:
		self.isHighJumping = false
			
	# If we ARE high high jumping, apply a lesser gravity to the player
	if self.isHighJumping and player.velocity.y < JUMP_VEL_LIMIT:
		currentGrav = JUMP_GRAVITY
		
	# If we ARENT high jumping and the player canceled early, apply a heavier gravity
	if !self.isHighJumping and player.velocity.y < 0 and self.canceledEarly:
		currentGrav = CANCELLED_JUMP_GRAVITY
	
	Common.handleAirMovement(player, delta, currentGrav)
	
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
		if !self.firstUpdate && Common.shouldWallJump(player):
			player.transition_to_state(player.get_node("States/WallJumping"))
		elif Common.shouldWallDrag(player):
			# Otherwise, if they've stopped ascending and holding input against a wall, start the wall drag
			player.transition_to_state(player.get_node("States/WallDragging"))	


func end(player):
	self.isHighJumping = false
	self.canceledEarly = false
	
func getName():
	return "Jumping"
