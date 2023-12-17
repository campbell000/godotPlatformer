@tool
extends Node2D

var timeElapsed: float = 0
var colorTimer = 0
var colorInterval = 0.05
var collisionShape: CollisionShape2D
@onready var line2D: Line2D = $Line2D
@onready var colorRect: ColorRect = $ColorRect
@export var speed = 0
@export var isMoving = false

var COLORS = [
	Color(153.0/255.0, 0, 0, 1),
	Color(153.0/255.0, 0, 0, 1),
	Color(177.0/255.0, 54.0/255.0, 41.0/255.0, 1),
	Color(196.0/255.0, 90.0/255.0, 78.0/255.0, 1),
	Color(217.0/255.0, 124.0/255.0, 116.0/255.0, 1),
	Color(232.0/255.0, 158.0/255.0, 153.0/255.0, 1),
	Color(217.0/255.0, 124.0/255.0, 116.0/255.0, 1),
	Color(196.0/255.0, 90.0/255.0, 78.0/255.0, 1),
	Color(177.0/255.0, 54.0/255.0, 41.0/255.0, 1),
]
var currentColor = 0

@export var WIDTH = 20.0
@export var HEIGHT = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	self.timeElapsed = 0
	self.collisionShape = get_node("Area2D/CollisionShape2D")
	self.collisionShape.shape.size = Vector2(WIDTH, HEIGHT)
	self.line2D.clear_points()
	self.line2D.add_point(Vector2(0, (-HEIGHT / 2.0)))
	self.line2D.add_point(Vector2(0, (HEIGHT / 2.0)))
	self.line2D.width = WIDTH
	self.colorRect.position = Vector2((WIDTH / 2.0), (-HEIGHT / 2.0))
	self.colorRect.size = Vector2(600, HEIGHT)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if isMoving && !Engine.is_editor_hint():
		self.position.x = self.position.x + (self.speed * delta)
	self.timeElapsed = self.timeElapsed + delta
	self.colorTimer = self.colorTimer + delta
	
	if self.colorTimer >= self.colorInterval:
		self.colorTimer = 0
		self.currentColor = self.currentColor + 1
		if currentColor >= len(COLORS):
			currentColor = 0
	
func _process(delta):
	self.line2D.default_color = COLORS[self.currentColor]
