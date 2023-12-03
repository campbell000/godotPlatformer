extends Node2D

@onready var backgroundTileset = $World/Environment/Tiles/BackgroundTileMap
@onready var player = $World/Environment/Player
@onready var chipDestroyedDialogResource = load("res://asset_files/dialog/firstChipDestroyed.dialogue")
func _ready():
	EventBus.chip_destroyed.connect(chipDestroyed)

func lockRoom():
	backgroundTileset.set_cell(1, Vector2i(192, -15), 0, Vector2i(11, 2))
	backgroundTileset.set_cell(1, Vector2i(193, -15), 0, Vector2i(11, 2))
	backgroundTileset.set_cell(1, Vector2i(194, -15), 0, Vector2i(11, 2))
	backgroundTileset.set_cell(1, Vector2i(192, -16), 0, Vector2i(11, 2))
	backgroundTileset.set_cell(1, Vector2i(193, -16), 0, Vector2i(11, 2))
	backgroundTileset.set_cell(1, Vector2i(194, -16), 0, Vector2i(11, 2))
	backgroundTileset.set_cell(1, Vector2i(192, -17), 0, Vector2i(11, 2))
	backgroundTileset.set_cell(1, Vector2i(193, -17), 0, Vector2i(11, 2))
	backgroundTileset.set_cell(1, Vector2i(194, -17), 0, Vector2i(11, 2))


func chipDestroyed():
	Dialog.startDialog(chipDestroyedDialogResource, player, Callable(), true)
	self.startChipChase()

func startChipChase():
	backgroundTileset.set_cell(1, Vector2i(192, -15), -1)
	backgroundTileset.set_cell(1, Vector2i(193, -15), -1)
	backgroundTileset.set_cell(1, Vector2i(194, -15), -1)
	backgroundTileset.set_cell(1, Vector2i(192, -16), -1)
	backgroundTileset.set_cell(1, Vector2i(193, -16), -1)
	backgroundTileset.set_cell(1, Vector2i(194, -16), -1)
	backgroundTileset.set_cell(1, Vector2i(192, -17), -1)
	backgroundTileset.set_cell(1, Vector2i(193, -17), -1)
	backgroundTileset.set_cell(1, Vector2i(194, -17), -1)
