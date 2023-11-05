@tool
extends Node2D

@export var shouldRepeat = false
@export var dialogResourceName = ""
@export var seeThrough = false
@export var stopWorld = false
var dialogBubble = null
var resource = null
var played = false
signal stop_world_started
signal stop_world_ended

@onready var collisionShape = $Area2D/CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready():
	self.resource = load("res://asset_files/dialog/"+dialogResourceName+".dialogue")
	self.dialogBubble = Common.getDialogBubble(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_2d_area_entered(area):
	if (!played || shouldRepeat):
		self.played = true
		self.dialogBubble.start(resource, self.seeThrough)
		if self.stopWorld:
			self.connect("dialog_ended", self.dialogEnded)
			stop_world_started.emit()


func dialogEnded():
	self.disconnect("dialog_ended", self.dialogEnded)
	self.stop_world_ended.emit()
