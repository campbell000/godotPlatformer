@tool
extends Node2D

@export var width = 100
@export var height = 100
@export var gravityModifier = 0.47

@onready var collisionShape = $Area2D/CollisionShape2D
@onready var colorRect:ColorRect = $ColorRect
@onready var particles:GPUParticles2D = $GPUParticles2D
var player = null

# Called when the node enters the scene tree for the first time.
func _ready():
	self.collisionShape.shape.size.x = width
	self.collisionShape.shape.size.y = height
	self.colorRect.size.x = width
	self.colorRect.size.y = height
	self.colorRect.position.x = -width / 2
	self.colorRect.position.y = -height / 2
	self.particles.position.y = height / 2
	self.particles.visibility_rect = Rect2(-width / 2, -height, width, height)
	self.particles.process_material.emission_box_extents = Vector3(-width / 2, 0, 1)
	self.particles.amount = width / 10
	self.particles.lifetime = height / 100 # assumption is 100px/sec

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
