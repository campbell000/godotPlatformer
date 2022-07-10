extends KinematicBody2D


var score: int = 0

var speed: int = 100
var jumpForce: int = 200
var gravity: int = 800

var vel: Vector2 = Vector2()
var grounded: bool = false

onready var sprite = $Sprite


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	# reset horizontal velocity
	vel.x = 0
	# movement inputs
	if Input.is_action_pressed("move_left"):
		vel.x -= speed
	if Input.is_action_pressed("move_right"):
		vel.x += speed
	# applying the velocity
	vel = move_and_slide(vel, Vector2.UP)

	# gravity
	vel.y += gravity * delta
	# jump input
	if Input.is_action_pressed("jump") and is_on_floor():
		vel.y -= jumpForce

	# sprite direction
	if vel.x < 0:
		sprite.flip_h = true
	elif vel.x > 0:
		sprite.flip_h = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
