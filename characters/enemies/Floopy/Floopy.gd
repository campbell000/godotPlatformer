extends Node2D

var verticalLimit = 5.0
var horizontalLimit = 25.0
var originalX
var originalY
var slowDownMaxX
var slowDownMinX
var slowDownMaxY
var slowDownMinY
var currentAccel = 1
var xVel = 5
var xMaxSpeed = 50
var yVel = 1
var yMaxSpeed = 30
var yAccel = 1
var xAccel = 1
var movingRight = true
var movingUp = true
var movingUpFPS = 1.1
var movingDownFPS = 0.6

@onready var animatedSprite = $AnimatedSprite2D

func isBouncy():
	return true
	

# Called when the node enters the scene tree for the first time.
func _ready():
	originalX = self.position.x
	originalY = self.position.y
	slowDownMaxX = originalX + (horizontalLimit/2)
	slowDownMinX = originalX - (horizontalLimit/2)
	slowDownMaxY = originalY + (verticalLimit/2)
	slowDownMinY = originalY - (verticalLimit/2)
	animatedSprite.play()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.xVel = calcVel(self.position.x, xVel, xAccel, xMaxSpeed, delta, movingRight)
	self.position.x = self.position.x + (xVel * delta)
	self.movingRight = self.manageState(self.position.x, slowDownMinX, slowDownMaxX, self.movingRight, true, false)
	
	self.yVel = calcVel(self.position.y, yVel, yAccel, yMaxSpeed, delta, movingUp)
	self.position.y = self.position.y + (yVel * delta)
	self.movingUp = self.manageState(self.position.y, slowDownMinY, slowDownMaxY, self.movingUp, false, true)
	
func calcVel(currentPosition, currentVel, accel, maxSpeed, delta, isMovingInDirection):
	if isMovingInDirection:
		currentVel += accel
	elif !isMovingInDirection:
		currentVel -= accel
		
	if currentVel > maxSpeed:
		currentVel = maxSpeed
	if currentVel < -maxSpeed:
		currentVel = -maxSpeed
		
	return currentVel

func manageState(pos, slowDownMin, slowDownMax, currentDir, flipSprite, adjustFps):
	if pos > slowDownMax:
		currentDir = false
		if flipSprite:
			self.animatedSprite.flip_h = true
		if adjustFps:
			self.animatedSprite.set_speed_scale(movingUpFPS) #Remember: moving Up means SUBTRACTING from y
	if pos < slowDownMin:
		currentDir = true
		if flipSprite:
			self.animatedSprite.flip_h = false
		if adjustFps:
			print(movingDownFPS)
			self.animatedSprite.set_speed_scale(movingDownFPS) 
	
	return currentDir


func _on_hit_box_area_entered(area: Area2D):
	if (area.collision_layer == Globals.ATTACK_LAYER):
		var player = area.get_parent()
		player.bounce()
		self.queue_free()
