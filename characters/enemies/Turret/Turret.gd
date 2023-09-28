extends Node2D

@onready var animation = $AnimatedSprite2D


var activated = false
var player = null
var MOVEMENT_SPEED = 50

# Called when the node enters the scene tree for the first time.
func _ready():
	animation.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.activated:
		animation.stop()
		var xDistanceAway = self.player.position.x - self.position.x
		if (xDistanceAway >= 0):
			animation.frame = 13
		else:
			animation.stop()
			animation.frame = 5
	else:
		animation.play()


func _on_area_2d_area_entered(area: Area2D):
	self.activated = true
	self.player = area.get_parent()



func _on_area_2d_area_exited(area):
	self.activated = false
	self.player = null
