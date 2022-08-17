extends KinematicBody2D

const DOWN_SNAP = Vector2(0, -32)

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
const JUMP_FORCE: float = 235.0

# Once the player's vel is at or over this limit (i.e. towards the apex of their jump), regular GRAVITY gets applied
# Primarily used so that the jump isn't as floaty looking. Also, increase this value so that the player needs to
# hold down the jump button for less time (annoying to have to hold down the button for the ENTIRE duration of the jump)
const JUMP_VEL_LIMIT = -155.0

const JUMP_BUFFER_TIME_WINDOW = 0.07

# state variables
var isMoving: bool = false
var isFacingForward: bool = false
var velocity: Vector2 = Vector2()
var prevVector: Vector2 = Vector2()
var isJumping: bool = false
var jumpHoldTimer = 0
var isHighJumping = false
var jumpHasBeenReleased = true
var hasBufferedJump = false
var bufferTimer = 0.0


# Scene Nodes
onready var animatedSprite = $AnimatedSprite

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	self._handlePlayerAnimation(delta)
		

# All of this is placeholder physics logic
func _physics_process(delta):
	# First, handle the inputs. 
	self._handlePlayerInputsPrior(delta)
	
	# Handle ground movement differently, depending on whether we're in the air on ground
	var snapVector
	if is_on_floor():
		self.isJumping = false
		self._handleHorizontalGround(delta)
		snapVector = self._handleVerticalGround(delta)
	else:
		self._handleHorizontalAir(delta)
		snapVector = self._handleVerticalAir(delta)
	
	self.velocity = move_and_slide_with_snap(self.velocity, snapVector, Vector2.UP)
	self._handlePlayerState(delta)
	self.prevVector = Vector2(self.velocity.x, self.velocity.y)
	
	self._handlePlayerInputsAfter(delta)
	
# Concept: allow for snappy, but subtly weighted, ground movement
func _handleHorizontalGround(delta):
	if Input.is_action_pressed("move_left"):
		self.velocity.x  = self.velocity.x - (RUN_ACCEL * delta)
	elif Input.is_action_pressed("move_right"):
		self.velocity.x = self.velocity.x + (RUN_ACCEL * delta)
	else:
		self.velocity.x = self.velocity.x / (1 + (GROUND_DRAG * delta))
		
	if self.velocity.x > MAX_RUN_SPEED:
		self.velocity.x = MAX_RUN_SPEED
	if self.velocity.x < -MAX_RUN_SPEED:
		self.velocity.x = -MAX_RUN_SPEED
		
	# Dont allow tiny numbers for this
	if self.velocity.x < 10 and self.velocity.x > -10:
		self.velocity.x = 0

func _handleVerticalGround(delta):
	var snapVector = DOWN_SNAP
	if (Input.is_action_just_pressed("jump") || self.bufferTimer > 0) and is_on_floor() and self.jumpHasBeenReleased:
		if (!Input.is_action_just_pressed("jump") && self.bufferTimer > 0):
			print("BUFFERED!")
		elif Input.is_action_just_pressed("jump"):
			print("Jumped normally!")
		self.velocity.y -= JUMP_FORCE
		snapVector = Vector2.ZERO	
		self.isJumping = true
		self.isHighJumping = true
		self.jumpHoldTimer = 0
	
	self.velocity.y += GRAVITY * delta
	return snapVector

func _handleVerticalAir(delta):
	self.jumpHoldTimer += delta
	var gravity = GRAVITY
	
	if self.isJumping and self.isHighJumping:
		if !Input.is_action_pressed("jump"):
			self.isHighJumping = false
	
	if self.isJumping and self.isHighJumping and self.velocity.y < JUMP_VEL_LIMIT:
		gravity = JUMP_GRAVITY
		
	self.velocity.y += gravity * delta
	return DOWN_SNAP
	
# In the air, the following holds true:
# - If forward is NOT held, slowly decelerate (i.e. air drag)
# - If forward IS held, same speed as ground but DONT allow gaining speed
# - If BACKWARDS is held, allow SLOW change of movement (forgiveness)
func _handleHorizontalAir(delta):
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
		
# TODO: this isn't working right. Dont think the "jump has been released" variable is being set properly (esp setting to false)
# This is causing delayed jumps
func _handlePlayerInputsPrior(delta):
	if Input.is_action_just_pressed("jump"):
		self.bufferTimer = JUMP_BUFFER_TIME_WINDOW
		
func _handlePlayerInputsAfter(delta):
	pass

func _handlePlayerState(delta):
	self.isMoving = false
	
	if self.velocity.x != 0:
		self.isMoving = true

	if self.velocity.x > 0:
		self.isFacingForward = true
	elif self.velocity.x < 0:
		self.isFacingForward = false
		
	if self.bufferTimer > 0:
		self.bufferTimer -= delta
	
func _handlePlayerAnimation(delta):
	if self.isMoving:
		self.animatedSprite.play("Run")
	else:
		self.animatedSprite.play("Idle")
		
	if self.velocity.x < 0:
		self.animatedSprite.flip_h = true
	elif self.velocity.x > 0:
		self.animatedSprite.flip_h = false
