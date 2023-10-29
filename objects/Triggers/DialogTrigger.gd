extends Node2D

@export var shouldRepeat = false
@export var dialogResourceName = ""
@export var seeThrough = false
var dialogBubble = null
var resource = null
var played = false


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
