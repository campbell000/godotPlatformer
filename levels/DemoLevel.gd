extends Node2D

var resource = load("res://asset_files/dialog/test.dialogue")
@onready var dialogBubble = $Interface/DialogBubble
var called = false

# Called when the node enters the scene tree for the first time.
func _ready():
	self.dialogBubble.start(resource, true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
		
var get_current_scene: Callable = func():
	var current_scene: Node = get_tree().current_scene
	if current_scene == null:
		current_scene = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
	return current_scene
