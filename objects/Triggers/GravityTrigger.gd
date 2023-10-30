@tool
extends Node2D

@export var width = 100
@export var height = 100

@onready var collisionShape = $Area2D/CollisionShape2D
@onready var colorRect:ColorRect = $ColorRect
@onready var particles:GPUParticles2D = $GPUParticles2D

# Called when the node enters the scene tree for the first time.
func _ready():
	print(width)
	print(height)
	print(self.colorRect)
	self.collisionShape.shape.size.x = width
	self.collisionShape.shape.size.y = height
	self.colorRect.size.x = width
	self.colorRect.size.y = height
	self.colorRect.position.x = -width / 2
	self.colorRect.position.y = -height / 2
	self.particles.visibility_rect = Rect2(-width / 2, -height / 2, width, height)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
