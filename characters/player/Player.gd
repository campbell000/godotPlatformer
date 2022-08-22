extends Character
class_name Player

const DOWN_SNAP = Vector2(0, -32)
const LEFT_SNAP = Vector2(-32, 0)
const RIGHT_SNAP = Vector2(32, 0)

# Max speed the player can be moving due to simply running (TODO: factor in things that affect speed)
const MAX_RUN_SPEED: float = 200.0

# Rate at which the player gains speed
const RUN_ACCEL: float = 1000.0

# Rate at which the player gains speed in the air. Slower so that jumps are more committal
const AIR_ACCEL: float = 530.0

# Constant that slows the player down on the ground when they are moving, but not pressing buttons
const GROUND_DRAG: float = 10.0

# Consttant that slows the player down in teh air when they are moving, but not pressing buttons.
# Less drag than on ground
const AIR_DRAG: float = 2.0;

# Gravity of the player
const GRAVITY: float = 1000.0

# Gravity when the player is holding the JUMP button
const JUMP_GRAVITY: float = 300.0

# Initial velocity of the player's jump
const JUMP_FORCE: float = 215.0

# Once the player's vel is at or over this limit (i.e. towards the apex of their jump), regular GRAVITY gets applied
# Primarily used so that the jump isn't as floaty looking. Also, increase this value so that the player needs to
# hold down the jump button for less time (annoying to have to hold down the button for the ENTIRE duration of the jump)
const JUMP_VEL_LIMIT = -120.0

# The length of the buffer window. In other words, the maximum amount of time a user can press the jump button
# early
const JUMP_BUFFER_TIME_WINDOW = 0.07

const WALL_DRAG = 50.0
const NO_WALL_COLLISON = -1
const LEFT_WALL_COLLISION = 0
const RIGHT_WALL_COLLISION = 1
const WALL_JUMP_FORCE = Vector2(220, -275)
const WALL_JUMP_Y_VEL_THRESHOLD = -30

var snapVector = Vector2.DOWN
var velocity: Vector2 = Vector2()
var prevVector: Vector2 = Vector2()
var isMoving: bool = false
var isFacingForward: bool = true

# state variables
var doJump = false
var isJumping: bool = false
var isHighJumping = false
var canJump = true


var bufferTimer = 0.0
var canWallJump = false
var doWallJump = false
var isWallDragging = false
var isWallJumping = false

enum State {GROUND, JUMPING, FALLING, WALL_DRAG, WALL_JUMPING}

# Scene Nodes
onready var animatedSprite = $AnimatedSprite
onready var collisionShape = $CollisionShape2D
onready var leftRaycast = $RaycastContainer/LeftRaycast
onready var rightRaycast = $RaycastContainer/RightRaycast
onready var debugStateLabel = $DebugStateLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	self.state = self.get_node("States/OnGround")
	pass # Replace with function body.

func _process(delta):
	pass
		

# All of this is placeholder physics logic
func _physics_process(delta):
	# First, handle the inputs. 
	self.state.update(self, delta)
	self.velocity = move_and_slide_with_snap(self.velocity, self.snapVector, Vector2.UP)
	self.prevVector = Vector2(self.velocity.x, self.velocity.y)
	self.state.update_after_move(self, delta)
	self._handlePlayerStateAfterMove(delta)
	self.debugStateLabel.text = self.state.getName()

func _handlePlayerStateAfterMove(delta):
	if self.bufferTimer > 0:
		self.bufferTimer -= delta
		
	if Input.is_action_pressed("move_left"):
		self.isFacingForward = false
	elif Input.is_action_pressed("move_right"):
		self.isFacingForward = true
		
	if !self.isFacingForward:
		self.animatedSprite.flip_h = true
	elif self.isFacingForward:
		self.animatedSprite.flip_h = false
		
func collidedWithLeftWall():
	return self.leftRaycast.is_colliding()
	
func collidedWithRightWall():
	return self.rightRaycast.is_colliding()
