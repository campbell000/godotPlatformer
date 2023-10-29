extends CanvasLayer
class_name DialogBubble


signal actioned(next_id)

const DIALOGUE_PITCHES = {
	alex = 0.8,
	Coco = 1
}

const DialogueLine = preload("res://addons/dialogue_manager/dialogue_line.gd")

@onready var talk_sound: AudioStreamPlayer = $AudioStreamPlayer
@onready var balloon := $Panel
@onready var margin := $Panel/Margin
@onready var character_label := $Panel/MarginBox/Container/VBoxContainer/CharacterLabel
@onready var character_portrait := $Panel/MarginBox/Container/Portrait
@onready var dialogue_label := $Panel/MarginBox/Container/VBoxContainer/DialogLabel
@onready var oldModulate = balloon.modulate
@onready var seeThroughModulate = Color(Color.WHITE, 0.65)
var dialogue: DialogueLine
var is_waiting_for_input: bool = false
var currDialogResource




func start(dialogResource: DialogueResource, seeThrough: bool = false) -> void:
	if seeThrough:
		self.balloon.modulate = self.seeThroughModulate
	else:
		self.balloon.modulate = self.oldModulate
	self.balloon.show()
	self.currDialogResource = dialogResource
	next("start")
	
func next(id):
	var dialogue_line = await DialogueManager.get_next_dialogue_line(self.currDialogResource, id)
	self.dialogue = dialogue_line
	if dialogue_line != null:
		character_label.text = dialogue_line.character
		character_portrait.texture = load("res://asset_files/portraits/%s.png" % [dialogue_line.character.to_lower()])
		dialogue_label.dialogue_line = dialogue_line
		if not dialogue_line.text.is_empty():
			dialogue_label.type_out()
			await dialogue_label.finished_typing
			
		var time = 2 + dialogue_line.text.length() * 0.02 if dialogue_line.time == null else dialogue_line.time.to_float()
		await get_tree().create_timer(time).timeout
		next(dialogue_line.next_id)	
	else:
		self.balloon.hide()

func _on_dialog_label_spoke(letter, letter_index, speed):
	if not letter in [" ", "."]:
		var actual_speed: int = 4 if speed >= 1 else 2
		if letter_index % actual_speed == 0 && dialogue != null:
			talk_sound.play()
			var pitch = DIALOGUE_PITCHES.get(dialogue.character, 1)
			talk_sound.pitch_scale = randf_range(pitch - 0.1, pitch + 0.1)
