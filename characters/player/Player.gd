extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Constants
const runSpeed: float = 150.0
const jumpForce: float = 290.0
const gravity: float = 800.0
const NO_SNAP = Vector2.ZERO
const DOWN_SNAP = Vector2(0, -32)

# state variables
var isMoving: bool = false
var velocity: Vector2 = Vector2()

# Scene Nodes
onready var animatedSprite = $AnimatedSprite

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# All of this is placeholder physics logic
# NOTE: GODOT src seems to already calculate everything by delta, so no need to do it here
func _physics_process(delta):
	self.velocity.x = 0
	var snapVector = DOWN_SNAP
	
	if Input.is_action_pressed("move_left"):
		self.velocity.x -= self.runSpeed
	elif Input.is_action_pressed("move_right"):
		self.velocity.x += self.runSpeed
		
	if Input.is_action_pressed("jump") and is_on_floor():
		self.velocity.y -= jumpForce
		snapVector = NO_SNAP	
	
	self.velocity.y += gravity * delta
	
	self.velocity = move_and_slide_with_snap(self.velocity, snapVector, Vector2.UP)
	self.handlePlayerState(delta)

func handlePlayerState(delta):
	self.isMoving = false
	
	if self.velocity.x != 0:
		self.isMoving = true

func _process(delta):
	self.handlePlayerAnimation(delta)
		
	
func handlePlayerAnimation(delta):
	if self.isMoving:
		self.animatedSprite.play("Run")
	else:
		self.animatedSprite.play("Idle")
		
	if self.velocity.x < 0:
		self.animatedSprite.flip_h = true
	elif self.velocity.x > 0:
		self.animatedSprite.flip_h = false
