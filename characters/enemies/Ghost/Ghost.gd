@tool
extends Node2D

@onready var animation = $AnimatedSprite2D
#@onready var animation = $BackBufferCopy/AnimatedSprite2D

var activated = false
var player = null
var MOVEMENT_SPEED = 50

# Called when the node enters the scene tree for the first time.
func _ready():
	animation.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.activated:
		var xDistanceAway = self.player.position.x - self.position.x
		var yDistanceAway = self.player.position.y - self.position.y
		var angle = atan2(yDistanceAway, xDistanceAway)
		var xImpulse = cos(angle) * delta * MOVEMENT_SPEED
		var yImpulse = sin(angle) * delta * MOVEMENT_SPEED
		self.position.x += xImpulse
		self.position.y += yImpulse
		if (xImpulse < 0):
			self.scale.x = 1
		else:
			self.scale.x = -1


func _on_area_2d_area_entered(area: Area2D):
	if (area.collision_layer == Globals.ATTACK_LAYER):
		self.queue_free()


func activationAreaEntered(area: Area2D):
	self.activated = true
	self.player = area.get_parent()
