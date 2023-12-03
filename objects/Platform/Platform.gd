extends AnimatableBody2D

@export var maxXDelta = 10
@export var maxYDelta = 0
@export var xAccel = 2
@export var yAccel = 0
@export var xMaxSpeed = 0.5
@export var yMaxSpeed = 0
@export var timeDelay = 0.0
var timeElapsed = 0
var originalX
var originalY
var maxX = 0
var maxY = 0
var vel = Vector2()
var RIGHT = 0
var LEFT = 1
var xDir = RIGHT
var yDir = RIGHT

# Called when the node enters the scene tree for the first time.
func _ready():
	self.originalX = self.position.x
	self.originalY = self.position.y
	self.maxX = self.position.x + self.maxXDelta
	self.maxY = self.position.y + self.maxYDelta
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _physics_process(delta):
	self.timeElapsed += delta
	if self.timeElapsed >= self.timeDelay:
		var xResults = self.calcMovement(delta, self.vel.x, self.position.x, self.xAccel, self.xDir, xMaxSpeed, originalX, maxX)
		self.xAccel = xResults[0]
		self.vel.x = xResults[1]
		self.xDir = xResults[3]
		var yResults = self.calcMovement(delta, self.vel.y, self.position.y, self.yAccel, self.yDir, yMaxSpeed, originalY, maxY)
		self.yAccel = yResults[0]
		self.vel.y = yResults[1]
		self.yDir = yResults[3]
		self.position = Vector2(xResults[2], yResults[2])

func calcMovement(delta, vel, pos, accel, dir, maxSpeed, originalPos, maxPos):
	vel += (delta * accel)
	if vel > maxSpeed:
		vel = maxSpeed
	if vel < -maxSpeed:
		vel = -maxSpeed
	
	pos += vel
	if (pos > maxPos && dir == RIGHT) || (pos < originalPos && dir == LEFT):
		dir = LEFT if dir == RIGHT else RIGHT
		accel = -accel
	
	return [accel, vel, pos, dir]
