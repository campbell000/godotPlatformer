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


func _ready() -> void:
	if not dialogue:
		queue_free()
		return
		
	balloon.hide()
	
	var viewport_size = balloon.get_viewport_rect().size
	margin.rect_size.x = viewport_size.x * 0.9
	
	if dialogue.character != "":
		character_label.visible = true
		character_label.bbcode_text = dialogue.character
		character_portrait.texture = load("res://portraits_balloon/portraits/%s.png" % dialogue.character)
	else:
		character_label.visible = false
	
	dialogue_label.rect_size.x = dialogue_label.get_parent().rect_size.x
	dialogue_label.dialogue = dialogue
	await dialogue_label.reset_height().completed
	
	# Make sure our responses get included in the height reset
	margin.rect_size = Vector2(0, 0)
	
	await get_tree().idle_frame
	
	balloon.rect_min_size = margin.rect_size
	balloon.rect_size = Vector2(0, 0)
	balloon.rect_global_position = Vector2((viewport_size.x - balloon.rect_size.x) * 0.5, viewport_size.y - balloon.rect_size.y)
	
	# Show our box
	balloon.visible = true
	
	dialogue_label.type_out()
	await dialogue_label.finished
	
	if dialogue.time != null:
		var time = dialogue.dialogue.length() * 0.02 if dialogue.time == "auto" else dialogue.time.to_float()
		await get_tree().create_timer(time).timeout
		next(dialogue.next_id)
	else:
		is_waiting_for_input = true
		balloon.focus_mode = Control.FOCUS_ALL
		balloon.grab_focus()
		

func next(next_id: String) -> void:
	emit_signal("actioned", next_id)
	queue_free()


### Helpers


func configure_focus() -> void:
	
	var items = get_responses()
	for i in items.size():
		var item: Control = items[i]
		
		item.focus_mode = Control.FOCUS_ALL
		
		item.focus_neighbour_left = item.get_path()
		item.focus_neighbour_right = item.get_path()
		
		if i == 0:
			item.focus_neighbour_top = item.get_path()
			item.focus_previous = item.get_path()
		else:
			item.focus_neighbour_top = items[i - 1].get_path()
			item.focus_previous = items[i - 1].get_path()
		
		if i == items.size() - 1:
			item.focus_neighbour_bottom = item.get_path()
			item.focus_next = item.get_path()
		else:
			item.focus_neighbour_bottom = items[i + 1].get_path()
			item.focus_next = items[i + 1].get_path()
	
	items[0].grab_focus()


func get_responses() -> Array:
	var items: Array = []
		
	return items


### Signals


func _on_response_mouse_entered(item):
	item.grab_focus()


func _on_response_gui_input(event, item):
	if event is InputEventMouseButton and event.is_pressed():
		next(dialogue.responses[item.get_index()].next_id)
	elif event.is_action_pressed("ui_accept") and item in get_responses():
		next(dialogue.responses[item.get_index()].next_id)


# When there are no response options the balloon itself is the clickable thing
func _on_Balloon_gui_input(event):
	if not is_waiting_for_input: return
	
	get_tree().set_input_as_handled()
	
	if event is InputEventMouseButton and event.is_pressed():
		next(dialogue.next_id)
	elif event.is_action_pressed("ui_accept") and balloon.get_focus_owner() == balloon:
		next(dialogue.next_id)
