extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var PLAYER_NODE_PATH = '/root/GameNode/World/Environment/Player'
var CAMERA_NODE_PATH = '/root/GameNode/Camera2D'

# NOTE: Layer = where the node is, Mask = What it collides with
var ATTACK_LAYER = 3
var HURTBOX_LAYER = 2
var DELETE_RAY_LAYER = 5
var GRAVITY_LAYER = 6
var ENEMY_ACTIVATION_LAYER = 4


var TILE_SIZE = 16

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
static func hasCollidedWithLayer(collisionLayer, layerToCheck):
	var bitmask = 1 << layerToCheck - 1
	return collisionLayer & bitmask != 0


