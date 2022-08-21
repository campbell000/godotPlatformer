extends KinematicBody2D

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
const WALL_JUMP_FORCE = Vector2(220, -260)

# state variables
var isMoving: bool = false
var isFacingForward: bool = false
var velocity: Vector2 = Vector2()
var prevVector: Vector2 = Vector2()
var doJump = false
var isJumping: bool = false
var isHighJumping = false
var canJump = true
var bufferTimer = 0.0
var canWallJump = false
var doWallJump = false
var isWallDragging = false


# Scene Nodes
onready var animatedSprite = $AnimatedSprite
onready var collisionShape = $CollisionShape2D
onready var leftRaycast = $RaycastContainer/LeftRaycast
onready var rightRaycast = $RaycastContainer/RightRaycast

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	self._handlePlayerAnimation(delta)
		

# All of this is placeholder physics logic
func _physics_process(delta):
	# First, handle the inputs. 
	self._handlePlayerStateBeforeMove(delta)
	
	# Handle ground movement differently, depending on whether we're in the air on ground
	var snapVector
	var wallCollision = self._is_near_wall(delta)
	if is_on_floor():
		snapVector = self._handleGroundMovement(delta)
	else:
		if wallCollision != NO_WALL_COLLISON:
			snapVector = self._handleWallMovement(delta, wallCollision)
		else:
			snapVector = self._handleAirMovement(delta)
	
	self.velocity = move_and_slide_with_snap(self.velocity, snapVector, Vector2.UP)
	print("==")
	self.prevVector = Vector2(self.velocity.x, self.velocity.y)
	
	
	self._handlePlayerStateAfterMove(delta)

func _handlePlayerStateBeforeMove(delta):
	# If the user JUST pressed jump, set the buffer timer
	if Input.is_action_just_pressed("jump"):
		self.bufferTimer = JUMP_BUFFER_TIME_WINDOW
	
	# Set the direction the player is facing
	if Input.is_action_pressed("move_left"):
		self.isFacingForward = false
	elif Input.is_action_pressed("move_right"):
		self.isFacingForward = true
		
	if self._is_near_wall(delta) == NO_WALL_COLLISON || is_on_floor():
		self.isWallDragging = false
		
func _handlePlayerInputsAfter(delta):
	pass
	
# Concept: allow for snappy, but subtly weighted, ground movement
func _handleGroundMovement(delta):
	###########################################
	# State management
	###########################################
	# If on floor, allow the player to jump again
	if is_on_floor():
		self.isJumping = false
		
	# If the user JUST pressed jump, set the buffer timer
	if Input.is_action_just_pressed("jump"):
		self.bufferTimer = JUMP_BUFFER_TIME_WINDOW
	
	# If the jump button was just pressed OR the user buffered a jump, and theyre on the ground, set the jump flag
	if (Input.is_action_just_pressed("jump") || self.bufferTimer > 0) and self.canJump:
		self.doJump = true
		self.isJumping = true
		self.isHighJumping = true
	
	###########################################
	# Horizontal Movement
	###########################################
	# If the user is pressing left or right, have the player start running
	if Input.is_action_pressed("move_left"):
		self.velocity.x  = self.velocity.x - (RUN_ACCEL * delta)
	elif Input.is_action_pressed("move_right"):
		self.velocity.x = self.velocity.x + (RUN_ACCEL * delta)
	else:
		self.velocity.x = self.velocity.x / (1 + (GROUND_DRAG * delta))
		
	# Don't let their ground speed exceed a maximum
	if self.velocity.x > MAX_RUN_SPEED:
		self.velocity.x = MAX_RUN_SPEED
	if self.velocity.x < -MAX_RUN_SPEED:
		self.velocity.x = -MAX_RUN_SPEED
		
	# Dont allow tiny numbers. Otherwise, the user will keep inching forward
	if self.velocity.x < 10 and self.velocity.x > -10:
		self.velocity.x = 0
	
	
	###########################################
	# Vertical Movement
	###########################################
	# If the user presses the jump button (or DID in the previous few frames) and is allowed to jump,
	# start jumping
	var snapVector = DOWN_SNAP
	var justJumped = false
	if self.doJump:
		self.doJump = false
		self.velocity.y -= JUMP_FORCE
		snapVector = Vector2.ZERO	
		justJumped = true
	
	# If we didnt JUST jump, have gravity apply its force on the player's y pos
	if !justJumped:
		self.velocity.y += GRAVITY * delta
	return snapVector
	
# In the air, the following holds true:
# - If forward is NOT held, slowly decelerate (i.e. air drag)
# - If forward IS held, same speed as ground but DONT allow gaining speed
# - If BACKWARDS is held, allow SLOW change of movement (forgiveness)
func _handleAirMovement(delta):
	###########################################
	# State management
	###########################################
	# If the user is currently jumping, but the jump button isn't being held down, stop ascending
	if self.isJumping and self.isHighJumping:
		if !Input.is_action_pressed("jump"):
			self.isHighJumping = false
	
	###########################################
	# Horizontal Movement
	###########################################
	var shouldDrag = !Input.is_action_pressed("move_left") && !Input.is_action_pressed("move_right")
	if shouldDrag:
		self.velocity.x = self.velocity.x / (1 + (AIR_DRAG * delta))
	else:
		var accel = 0
		if Input.is_action_pressed("move_left"):
			accel = -AIR_ACCEL
		elif Input.is_action_pressed("move_right"):
			accel = AIR_ACCEL
			
		self.velocity.x = self.velocity.x + (accel * delta)
		if self.velocity.x > MAX_RUN_SPEED:
			self.velocity.x = MAX_RUN_SPEED
		if self.velocity.x < -MAX_RUN_SPEED:
			self.velocity.x = -MAX_RUN_SPEED
			
	###########################################
	# Vertical Movement
	###########################################
	var gravity = GRAVITY
	if self.isJumping and self.isHighJumping and self.velocity.y < JUMP_VEL_LIMIT:
		gravity = JUMP_GRAVITY
		
	self.velocity.y += gravity * delta
	return DOWN_SNAP
	
func _handleWallMovement(delta, collisionSide):
	###########################################
	# State Management
	###########################################
	if self.isWallDragging:
		if collisionSide == RIGHT_WALL_COLLISION and Input.is_action_pressed("move_left"):
			self.isWallDragging = false
		elif collisionSide == LEFT_WALL_COLLISION and Input.is_action_pressed("move_right"):
			self.isWallDragging = false
	else:
		if self.velocity.y > 0:
			if collisionSide == LEFT_WALL_COLLISION and Input.is_action_pressed("move_left"):
				self.isWallDragging = true
			elif collisionSide == RIGHT_WALL_COLLISION and Input.is_action_pressed("move_right"):
				self.isWallDragging = true

	if isWallDragging:	
		if Input.is_action_just_pressed("jump"):
			self.velocity = WALL_JUMP_FORCE
			if collisionSide == RIGHT_WALL_COLLISION:
				self.velocity = WALL_JUMP_FORCE * Vector2(-1, 1)
			return DOWN_SNAP
		else:
			self.velocity.y = WALL_DRAG
			if collisionSide == LEFT_WALL_COLLISION:
				return LEFT_SNAP
			elif collisionSide == RIGHT_WALL_COLLISION:
				return RIGHT_SNAP
	else:
		return self._handleAirMovement(delta)

func _handlePlayerStateAfterMove(delta):
	self.isMoving = false
	
	if self.velocity.x != 0 || Input.is_action_pressed("move_left") || Input.is_action_pressed("move_right"):
		self.isMoving = true
		
	if self.bufferTimer > 0:
		self.bufferTimer -= delta
	
func _handlePlayerAnimation(delta):
	if self.isMoving:
		self.animatedSprite.play("Run")
	else:
		self.animatedSprite.play("Idle")
		
	if !self.isFacingForward:
		self.animatedSprite.flip_h = true
	elif self.isFacingForward:
		self.animatedSprite.flip_h = false
		
func _is_near_wall(delta):
	if self.leftRaycast.is_colliding():
		print("LEFT COLLISDE")
		return LEFT_WALL_COLLISION
	elif self.rightRaycast.is_colliding():
		print("RIGHT COLLIDE")
		return RIGHT_WALL_COLLISION
	else:
		return NO_WALL_COLLISON
