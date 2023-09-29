@tool
extends Node2D

var timeElapsed: float = 0
var colorInterval = 0.04
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

static var WIDTH = 2.0
static var LENGTH = 25

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint():
		self.drawLine()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.timeElapsed = self.timeElapsed + delta
	
	if self.timeElapsed >= self.colorInterval:
		self.queue_redraw()
		self.timeElapsed = 0
		self.currentColor = self.currentColor + 1
		if currentColor >= len(COLORS):
			currentColor = 0
	
func _draw():
	self.drawLine()
	
func drawLine():
	self.draw_line(Vector2(0, 0), Vector2(LENGTH, 0), COLORS[currentColor], WIDTH, false)
