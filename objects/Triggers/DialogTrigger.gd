@tool
extends Node2D

@export var shouldRepeat = false
@export var dialogResourceName = ""
@export var seeThrough = false
@export var stopWorld = false
var dialogBubble = null
var resource = null
var played = false
var player = null
var running = false

@onready var collisionShape = $Area2D/CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready():
	self.resource = load("res://asset_files/dialog/"+dialogResourceName+".dialogue")
	self.dialogBubble = Dialog.getDialogBubble(self)
	if self.stopWorld == null:
		self.stopWorld = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_2d_area_entered(area):
	if !self.running && (!played || shouldRepeat) && area.get_parent() is Player:
		self.running = true
		self.played = true
		Dialog.startDialog(self.resource, area.get_parent(), Callable(), self.stopWorld)


func dialogEnded():
	self.dialogBubble.disconnect("dialog_ended", self.dialogEnded)
	if self.stopWorld:
		await get_tree().create_timer(0.2).timeout
		self.player.unlockControls()
