extends Character
class_name Player

# The length of the buffer window. In other words, the maximum amount of time a user can press the jump button
# early
const JUMP_BUFFER_TIME_WINDOW = 0.08333

var bufferTimer = 0.0
var velocity: Vector2 = Vector2()
var prevVector: Vector2 = Vector2()
var isMoving: bool = false
var isFacingForward: bool = true
var allowedUnlimitedSpeed: bool = false
var isReturningToNormalSpeed: bool = false

var currentDirection = null

var isMaintainingInertia: bool = false
var maintainInertiaDrag: float = Physics.INITIAL_MAINTAIN_INERTIA_DRAG
const INERTIA_DRAG_INCREASE_PER_MS = 1

# Scene Nodes
onready var animatedSprite = $AnimatedSprite
onready var sprite = $Sprite
onready var collisionShape = $CollisionShape2D
onready var leftRaycast = $RaycastContainer/LeftRaycast
onready var rightRaycast = $RaycastContainer/RightRaycast
onready var debugStateLabel = $DebugStateLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	self.state = self.get_node("States/OnGround")
	self.sprite = $Sprite
	self.state.start(self)
	pass # Replace with function body.

func _process(delta):
	pass
		
# All of this is placeholder physics logic
func _physics_process(delta):
	# If the user JUST pressed jump, set the buffer timer
	if Input.is_action_just_pressed("jump"):
		self.bufferTimer = JUMP_BUFFER_TIME_WINDOW
		
	if Input.is_action_just_pressed("move_left"):
		self.currentDirection = "move_left"
	elif Input.is_action_just_pressed("move_right"):
		self.currentDirection = "move_right"

	# First, handle the inputs. 
	self.state.update(self, delta)
	self._handlePlayerStateAfterMove(delta)
	self.debugStateLabel.text = self.state.getName()+"\n"+str(self.velocity.x)
	
func justJumpedOrBufferedAJump():
	return Input.is_action_just_pressed("jump") || self.bufferTimer > 0

func _handlePlayerStateAfterMove(delta):
	if self.bufferTimer > 0:
		self.bufferTimer -= delta
		
	if Input.is_action_pressed("move_left") && self.velocity.x < 0:
		self.sprite.flip_h = true
	elif Input.is_action_pressed("move_right") && self.velocity.x > 0:
		self.sprite.flip_h = false
		
	if self.is_on_floor():
		self.sprite.rotation = get_floor_normal().angle() + PI/2
	else:
		self.sprite.rotation = 0
		
	if self.velocity.x <= Physics.MAX_RUN_SPEED and self.velocity.x >= -Physics.MAX_RUN_SPEED:
		self.isMaintainingInertia = false
		self.maintainInertiaDrag = Physics.INITIAL_MAINTAIN_INERTIA_DRAG
		
	if self.isMaintainingInertia:
		var before = self.maintainInertiaDrag
		self.maintainInertiaDrag = self.maintainInertiaDrag / (1 + (INERTIA_DRAG_INCREASE_PER_MS * delta))
		print(str(before)+" "+str(self.maintainInertiaDrag))
		
func collidedWithLeftWall():
	# NEED TO DIFFERENTIATE BETWEEN WALL AND ONE WAY FLOOR!!!!!
	return self.leftRaycast.is_colliding()
	
func collidedWithRightWall():
	return self.rightRaycast.is_colliding()
	
func isRunningDownHill():
	if self.is_on_floor():
		var angleOfSlope = get_floor_normal().angle() + PI/2
		if angleOfSlope > 0 and self.velocity.x > 0:
			return true
		elif angleOfSlope < -0.01 and self.velocity.x < 0:
			return true
		else:
			return false
	else:
		return false
	
func isOnSlope():
	return self.is_on_floor() and self.get_floor_normal().dot(Vector2.UP) != 1
	
# Returns the direction (left or right) that is currently being pressed. If both buttons are being held
# at the same time, then the most recent one wins (i.e. if a player is moving left but then switches right,
# but they hold left for a split second, we want to immediately start moving right)
func getDeconflictedDirectionalInput():
	if self.currentDirection != null && Input.is_action_pressed(self.currentDirection):
		return self.currentDirection
	elif Input.is_action_pressed("move_left"):
		return "move_left"
	elif Input.is_action_pressed("move_right"):
		return "move_right"
