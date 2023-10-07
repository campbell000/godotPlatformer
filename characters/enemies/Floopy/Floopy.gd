extends Node2D

var goingUp = false
var goingRight = false
var verticalLimit = 30.0
var horizontalLimit = 30.0
var originalX
var originalY
var maxX
var minX
var currentAccel = 1
var vel = 0
var maxSpeed = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	originalX = self.position.x
	originalY = self.position.y
	maxX = horizontalLimit + originalX
	minX = originalX
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	vel += currentAccel * delta
	if currentAccel > 0 && vel > maxSpeed:
		vel = maxSpeed
	if currentAccel < 0 && vel < -maxSpeed:
		vel = -maxSpeed
	if currentAccel > 0 && self.position.x >= maxX:
		currentAccel = currentAccel * -1
	if currentAccel < 0 && self.position.x <= minX:
		currentAccel = currentAccel * -1
	self.position.x = self.position.x + vel
	print(minX)
	print(maxX)
