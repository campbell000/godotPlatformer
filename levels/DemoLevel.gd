extends Node2D

@onready var backgroundTileset = $World/Environment/Tiles/BackgroundTileMap

func lockRoom():
	print("OK")
	backgroundTileset.set_cell(1, Vector2i(192, -15), 0, Vector2i(11, 2))
	backgroundTileset.set_cell(1, Vector2i(193, -15), 0, Vector2i(11, 2))
	backgroundTileset.set_cell(1, Vector2i(194, -15), 0, Vector2i(11, 2))
	backgroundTileset.set_cell(1, Vector2i(192, -16), 0, Vector2i(11, 2))
	backgroundTileset.set_cell(1, Vector2i(193, -16), 0, Vector2i(11, 2))
	backgroundTileset.set_cell(1, Vector2i(194, -16), 0, Vector2i(11, 2))
	backgroundTileset.set_cell(1, Vector2i(192, -17), 0, Vector2i(11, 2))
	backgroundTileset.set_cell(1, Vector2i(193, -17), 0, Vector2i(11, 2))
	backgroundTileset.set_cell(1, Vector2i(194, -17), 0, Vector2i(11, 2))


func _on_memory_chip_destroyed():
	print("Chip Was Destroyed")
