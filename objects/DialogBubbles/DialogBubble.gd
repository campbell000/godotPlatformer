extends CanvasLayer
class_name DialogBubble


signal actioned(next_id)


const DialogueLine = preload("res://addons/dialogue_manager/dialogue_line.gd")

@onready var balloon := $Panel
@onready var margin := $Panel/Margin
@onready var character_label := $Panel/MarginBox/Container/VBoxContainer/CharacterLabel
@onready var character_portrait := $Panel/MarginBox/Container/Portrait
@onready var dialogue_label := $Panel/MarginBox/Container/VBoxContainer/DialogLabel

var dialogue: DialogueLine
var is_waiting_for_input: bool = false
var currDialogResource


func start(dialogResource: DialogueResource) -> void:
	#if dialogue.character != "":
#		character_label.visible = true
#		character_label.bbcode_text = dialogue.character
#		character_portrait.texture = load("res://portraits_balloon/portraits/%s.png" % dialogue.character)
#	else:
#		character_label.visible = false
	self.balloon.show()
	self.currDialogResource = dialogResource
	next("start")
	
func next(id):
	var dialogue_line = await DialogueManager.get_next_dialogue_line(self.currDialogResource, id)
	if dialogue_line != null:
		character_label.text = dialogue_line.character
		character_portrait.texture = load("res://asset_files/portraits/%s.png" % [dialogue_line.character.to_lower()])
		dialogue_label.dialogue_line = dialogue_line
		if not dialogue_line.text.is_empty():
			dialogue_label.type_out()
			await dialogue_label.finished_typing
			
		var time = dialogue_line.text.length() * 0.1 if dialogue_line.time == null else dialogue_line.time.to_float()
		await get_tree().create_timer(time).timeout
		next(dialogue_line.next_id)	
	else:
		self.balloon.hide()


		
