extends Node2D

@onready var animation = $AnimatedSprite2D

var LASER_DELAY = 0.75
var LASER_TIMER = 2
var LASER_SPEED = 240

var activated = false
var player = null
var timeElapsed = 0
var laserScene = preload("res://characters/objects/TurretLaser/TurretLaser.tscn")
var laserInstance = null

var currLaserSpeed = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	animation.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.timeElapsed += delta
	if self.activated:
		animation.stop()
		var xDistanceAway = self.player.position.x - self.position.x
		if (xDistanceAway >= 0):
			animation.frame = 13
		else:
			animation.frame = 5
			
		if self.timeElapsed > LASER_TIMER:
			self.timeElapsed = 0
			if self.laserInstance != null:
				self.laserInstance.queue_free()
				self.laserInstance = null

			self.laserInstance = self.laserScene.instantiate()
			self.laserInstance.visible = true
			self.add_child(self.laserInstance)
			self.currLaserSpeed = LASER_SPEED * (1 if xDistanceAway >= 0 else -1)
			self.laserInstance.global_position.x = self.position.x
			self.laserInstance.global_position.y = self.position.y - 4
	else:
		animation.play()
		
	if self.laserInstance:
		self.laserInstance.position.x = self.laserInstance.position.x + (self.currLaserSpeed * delta)


func _on_area_2d_area_entered(area: Area2D):
	self.activated = true
	self.timeElapsed = LASER_TIMER - LASER_DELAY
	self.player = area.get_parent()



func _on_area_2d_area_exited(area):
	self.activated = false
	self.player = null
