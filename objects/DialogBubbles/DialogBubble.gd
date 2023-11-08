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
@onready var triangle = $Panel/Triangle
@onready var seeThroughModulate = Color(Color.WHITE, 0.65)
var dialogue: DialogueLine
var is_waiting_for_input: bool = false
var currDialogResource
var isSeeThrough = false
var isShowing = false
var NOONE_NAME = "noone"
@onready var triangleTimer := $Timer
signal dialog_ended

func _ready():
	self.balloon.hide()
	self.triangleTimer.connect("timeout", triangleVisibilityToggle)
	self.dialogue_label.connect("finished_typing", finishedTyping)

func start(dialogResource: DialogueResource, seeThrough: bool = false) -> void:
	self.isShowing = true
	self.isSeeThrough = seeThrough
	self.triangle.visible = false
	if seeThrough:
		self.balloon.modulate = self.seeThroughModulate
	else:
		self.balloon.modulate = self.oldModulate
	self.balloon.show()
	self.currDialogResource = dialogResource
	next("start")
	
func _input(event):
	if self.isShowing && !self.isSeeThrough:
		if event.is_action_pressed("attack") || event.is_action_pressed("jump"):
			var d: DialogueLabel = self.dialogue_label
			if d.is_typing:
				d.skip_typing()
			else:
				if (self.dialogue):
					next(self.dialogue.next_id)	
	
func startTriangleToggle():
	var testLine = await DialogueManager.get_next_dialogue_line(self.currDialogResource, self.dialogue.next_id)
	if (testLine != null):
		self.triangle.visible = true
		self.triangleTimer.start(0.5)
	else:
		print("W")
		
func finishedTyping():
	if (!self.isSeeThrough):
		self.startTriangleToggle()
		
func endTriangleToggle():
	self.triangleTimer.stop()
	
func triangleVisibilityToggle():
	self.triangle.visible = !self.triangle.visible
	
func next(id):
	self.endTriangleToggle()
	self.triangle.visible = false
	var dialogue_line = await DialogueManager.get_next_dialogue_line(self.currDialogResource, id)
	self.dialogue = dialogue_line
	if dialogue_line != null:
		if dialogue_line.character.to_lower() != NOONE_NAME:
			character_portrait.visible = true
			character_label.text = dialogue_line.character
			character_portrait.texture = load("res://asset_files/portraits/%s.png" % [dialogue_line.character.to_lower()])
		else:
			character_label.text = ""
			character_portrait.visible = false
		dialogue_label.dialogue_line = dialogue_line
		if not dialogue_line.text.is_empty():
			dialogue_label.type_out()
			if self.isSeeThrough:
				await dialogue_label.finished_typing
			
		if self.isSeeThrough:
			var time = 2 + dialogue_line.text.length() * 0.02 if dialogue_line.time == null else dialogue_line.time.to_float()
			await get_tree().create_timer(time).timeout
			next(dialogue_line.next_id)	
	else:
		self.endDialog()

func endDialog():
	dialog_ended.emit()
	self.balloon.hide()
	self.isShowing = false

func _on_dialog_label_spoke(letter, letter_index, speed):
	if not letter in [" ", "."]:
		var actual_speed: int = 4 if speed >= 1 else 2
		if letter_index % actual_speed == 0 && dialogue != null:
			talk_sound.play()
			var pitch = DIALOGUE_PITCHES.get(dialogue.character, 1)
			talk_sound.pitch_scale = randf_range(pitch - 0.1, pitch + 0.1)
