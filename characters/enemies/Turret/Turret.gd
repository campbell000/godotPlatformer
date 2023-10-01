extends Node2D

@onready var animation = $AnimatedSprite2D
@onready var oldModulate = animation.modulate

var LASER_DELAY = 1.25
var LASER_TIMER = 1.25
var LASER_SPEED = 240
var LASER_DURATION = 3
var INTER_BLINK_LENGTH = 0.07
var BLINK_LENGTH = 0.95
var DONT_BLINK = 0.25
var MAX_LASERS = 2

var activated = false
var player = null
var timeElapsed = 0
var laserScene = preload("res://characters/objects/TurretLaser/TurretLaser.tscn")
var blinkColor = Color.PALE_TURQUOISE

var interBlinkTimer = 0
var isBlunk = false

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
			self.interBlinkTimer = 0
			self.animation.modulate = self.oldModulate
			self.createNewLaser()
		else:
			if self.timeElapsed <= BLINK_LENGTH && self.timeElapsed >= DONT_BLINK:
				self.handleBlink(delta)
			elif self.timeElapsed >= DONT_BLINK:
				self.animation.modulate = blinkColor
			else:
				self.animation.modulate = oldModulate
	else:
		animation.play()

func createNewLaser():
	var laserInstance = self.laserScene.instantiate()
	var xDistanceAway = self.player.position.x - self.position.x
	laserInstance.speed = LASER_SPEED * (1 if xDistanceAway >= 0 else -1)
	laserInstance.duration = LASER_DURATION
	laserInstance.visible = true
	self.add_child(laserInstance)
	laserInstance.global_position.x = self.position.x
	laserInstance.global_position.y = self.position.y - 4

func handleBlink(delta):
	self.interBlinkTimer += delta
	if self.interBlinkTimer >= INTER_BLINK_LENGTH:
		self.interBlinkTimer = 0
		if self.isBlunk:
			self.animation.modulate = oldModulate
			self.isBlunk = false
		else:
			self.animation.modulate = blinkColor
			self.isBlunk = true

func _on_area_2d_area_entered(area: Area2D):
	self.activated = true
	self.timeElapsed = LASER_TIMER - LASER_DELAY
	self.player = area.get_parent()

func _on_area_2d_area_exited(area):
	self.activated = false
	self.player = null
	self.isBlunk = false
	self.interBlinkTimer = 0
	self.timeElapsed = 0
