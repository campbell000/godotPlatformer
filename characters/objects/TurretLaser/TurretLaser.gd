@tool
extends Node2D

var timeElapsed: float = 0
var colorTimer = 0
var colorInterval = 0.02
var collisionShape: CollisionShape2D
@onready var line2D: Line2D = $Line2D

var COLORS = [
	Color(0.586275, 0.933333, 0.933333, 1),
	Color(0.686275, 0.933333, 0.933333, 1),
	Color(0.786275, 0.933333, 0.933333, 1),
	Color(0.886275, 0.933333, 0.933333, 1),
	Color(0.906275, 0.943333, 0.943333, 1),
	Color(0.886275, 0.933333, 0.933333, 1),
	Color(0.786275, 0.933333, 0.933333, 1),
	Color(0.686275, 0.933333, 0.933333, 1),
]
var currentColor = 0

@export var WIDTH = 2.0
@export var LENGTH = 20
@export var speed = 1
@export var duration = 1
@export var liveOnce = true
@export var offset = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	self.timeElapsed = offset
	self.collisionShape = get_node("Area2D/CollisionShape2D")
	self.collisionShape.shape.size = Vector2(LENGTH, WIDTH)
	self.line2D.clear_points()
	self.line2D.add_point(Vector2((-LENGTH / 2.0), 0))
	self.line2D.add_point(Vector2((LENGTH / 2.0), 0))
	self.line2D.width = WIDTH

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if !Engine.is_editor_hint():
		self.position.x = self.position.x + (self.speed * delta)
	self.timeElapsed = self.timeElapsed + delta
	self.colorTimer = self.colorTimer + delta
	
	if self.colorTimer >= self.colorInterval:
		self.colorTimer = 0
		self.currentColor = self.currentColor + 1
		if currentColor >= len(COLORS):
			currentColor = 0
			
	if self.duration != 0 && self.timeElapsed > self.duration && !Engine.is_editor_hint():
		self.timeElapsed = 0
		if liveOnce:
			self.queue_free()
		else:
			self.visible = !self.visible
			self.collisionShape.disabled = !self.collisionShape.disabled
	
func _process(delta):
	self.line2D.default_color = COLORS[self.currentColor]
	
func _on_area_2d_area_entered(area):
	pass # Replace with function body.
