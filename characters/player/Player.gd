extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Constants
const runSpeed: float = 190.0
const runAccel: float = 825.0
const jumpForce: float = 290.0
const gravity: float = 800.0
const groundDrag: float = 15.0
const airDrag: float = 50.0;
const NO_SNAP = Vector2.ZERO
const DOWN_SNAP = Vector2(0, -32)

# state variables
var isMoving: bool = false
var isFacingForward: bool = false
var velocity: Vector2 = Vector2()

# Scene Nodes
onready var animatedSprite = $AnimatedSprite

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# All of this is placeholder physics logic
# NOTE: GODOT src seems to already calculate everything by delta, so no need to do it here
func _physics_process(delta):
	var snapVector = DOWN_SNAP
	
	if Input.is_action_pressed("move_left"):
		self.velocity.x  = self.velocity.x - (runAccel * delta)
	elif Input.is_action_pressed("move_right"):
		self.velocity.x = self.velocity.x + (runAccel * delta)
	else:
		# TODO Different friction on ground vs in air
		self.velocity.x = self.velocity.x / (1 + (groundDrag * delta))
		
	if self.velocity.x > runSpeed:
		self.velocity.x = runSpeed
	if self.velocity.x < -runSpeed:
		self.velocity.x = -runSpeed
		
	if self.velocity.x < 1 and self.velocity.x > -1:
		self.velocity.x = 0
		
	if Input.is_action_pressed("jump") and is_on_floor():
		self.velocity.y -= jumpForce
		snapVector = NO_SNAP	
	
	self.velocity.y += gravity * delta
	
	self.velocity = move_and_slide_with_snap(self.velocity, snapVector, Vector2.UP)
	self._handlePlayerState(delta)

func _handlePlayerState(delta):
	self.isMoving = false
	
	if self.velocity.x != 0:
		self.isMoving = true

	if self.velocity.x > 0:
		self.isFacingForward = true
	elif self.velocity.x < 0:
		self.isFacingForward = false

func _process(delta):
	self._handlePlayerAnimation(delta)
		
	
func _handlePlayerAnimation(delta):
	if self.isMoving:
		self.animatedSprite.play("Run")
	else:
		self.animatedSprite.play("Idle")
		
	if self.velocity.x < 0:
		self.animatedSprite.flip_h = true
	elif self.velocity.x > 0:
		self.animatedSprite.flip_h = false
