extends Node2D
var dialogBubble = null
var dialogEndedCallback: Callable
var stopWorld = false
var player = null

signal dialogEnded

# Called when the node enters the scene tree for the first time.
func _ready():
	dialogBubble = getDialogBubble(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
static func getDialogBubble(node: Node2D):
	var r = node.get_tree().root.get_node("GameNode")
	return r.get_node("Interface/DialogBubble")

static func startDialog(dialogResource, player, dialogEndedCallback: Callable, stopWorld):
	Dialog.dialogEndedCallback = dialogEndedCallback
	Dialog.stopWorld = stopWorld
	Dialog.player = player
	Dialog.dialogBubble.connect("dialog_ended", Dialog._dialogEnded)
	Dialog.dialogBubble.start(dialogResource, !Dialog.stopWorld)
	if stopWorld:
		player.lockControls()

static func _dialogEnded():
	Dialog.dialogBubble.disconnect("dialog_ended", Dialog._dialogEnded)
	if Dialog.stopWorld:
		Dialog.player.unlockControls()
	if Dialog.dialogEndedCallback:
		Dialog.dialogEndedCallback.call()
