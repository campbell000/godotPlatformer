extends Node2D

var resource = load("res://asset_files/dialog/test.dialogue")
var called = false

@onready var dialogLabel: DialogueLabel = $Interface/DialogueLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	if !called:
		var ExampleBalloonScene = load("res://objects/DialogBubbles/DialogBubble.tscn")
		var balloon: DialogBubble =  ExampleBalloonScene.instantiate()
		get_current_scene.call().add_child(balloon)
		balloon.dialogue_label = dialogLabel
		balloon.dialogue_label.type_out()
		self.called = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
		
var get_current_scene: Callable = func():
	var current_scene: Node = get_tree().current_scene
	if current_scene == null:
		current_scene = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
	return current_scene
