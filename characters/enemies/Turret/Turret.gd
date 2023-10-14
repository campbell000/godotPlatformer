extends Node2D

@onready var animation = $AnimatedSprite2D
@onready var oldModulate = animation.modulate

var LASER_DELAY = 1.5
@export var LASER_TIMER = 1.5
var LASER_SPEED = 220
var LASER_DURATION = 3
var INTER_BLINK_LENGTH = 0.07
var BLINK_LENGTH = 0.95
var DONT_BLINK = 0.25
var MAX_LASERS = 2
@export var upsideDown = false
@export var alwaysFire = false

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
	if self.activated || self.alwaysFire:
		animation.stop()
		var xDistanceAway = -1 if self.player == null else self.player.position.x - self.position.x
		if (xDistanceAway >= 0 || self.upsideDown):
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
	var xDistanceAway = -1 if self.player == null else self.player.position.x - self.position.x
	laserInstance.speed = LASER_SPEED * (1 if xDistanceAway >= 0 else -1)
	laserInstance.speed = (-1 * laserInstance.speed) if upsideDown else laserInstance.speed
	laserInstance.duration = LASER_DURATION
	laserInstance.visible = true
	self.add_child(laserInstance)
	laserInstance.global_position.x = self.position.x
	laserInstance.global_position.y = self.position.y - 4
	if self.upsideDown:
		laserInstance.global_position.y = self.position.y + 4

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
	if (!self.alwaysFire):
		self.timeElapsed = LASER_TIMER - LASER_DELAY
	self.player = area.get_parent()

func _on_area_2d_area_exited(area):
	self.activated = false
	self.player = null
	if (!self.alwaysFire):
		self.timeElapsed = LASER_TIMER - LASER_DELAY
		self.isBlunk = false
		self.interBlinkTimer = 0
		self.timeElapsed = 0
