extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var player

var target

# The number of tiles that should appear BELOW the player when standing. 2 is chosen
# because that's kinda how much space SMW has below the player
const NUM_TILES_FROM_BOTTOM_OF_VIEWPORT = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	print(Globals.PLAYER_NODE_PATH)
	self.player = get_node(Globals.PLAYER_NODE_PATH)
	self.target = self.player


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.position.x = target.position.x
	self.position.y = target.position.y - getCameraYDisplacement()
	
func getCameraYDisplacement():
	# Determine the displacement required to move the camera so that there's N number of tiles visible
	# below the target
	var gameHeight = ProjectSettings.get_setting("display/window/size/height")
	var collisionShape = target.get_node("CollisionShape2D") as CollisionShape2D
	var distanceFromBottom = NUM_TILES_FROM_BOTTOM_OF_VIEWPORT * Globals.TILE_SIZE
	var playerDisplace = collisionShape.transform.y.y + (collisionShape.shape.extents.y)
	return (gameHeight / 2) - distanceFromBottom - playerDisplace
