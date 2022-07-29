extends Camera2D

const DEBUG_CAMERA_SPEED = 100

# The number of tiles that should appear BELOW the player when standing. 2 is chosen
# because that's kinda how much space SMW has below the player
const NUM_TILES_FROM_BOTTOM_OF_VIEWPORT = 2

var player
var target
var is_debug_freeform


# Called when the node enters the scene tree for the first time.
func _ready():
	self.player = get_node(Globals.PLAYER_NODE_PATH)
	self.target = self.player

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.handleDebugCamera(delta)
	if !is_debug_freeform:
		self.position.x = target.position.x
		self.position.y = target.position.y - getCameraYDisplacement()
		
func handleDebugCamera(delta):
	if Input.is_action_pressed("camera_down"):
		print("down")
		self.is_debug_freeform = true
		self.position.y += DEBUG_CAMERA_SPEED * delta
	if Input.is_action_pressed("camera_up"):
		print("up")
		self.is_debug_freeform = true
		self.position.y -= DEBUG_CAMERA_SPEED * delta
	if Input.is_action_pressed("camera_left"):
		print("left")
		self.is_debug_freeform = true
		self.position.x -= DEBUG_CAMERA_SPEED * delta
	if Input.is_action_pressed("camera_right"):
		print("right")
		self.is_debug_freeform = true
		self.position.x += DEBUG_CAMERA_SPEED * delta
		
	if Input.is_action_pressed("camera_reset"):
		self.is_debug_freeform = false
		
	# If debug, disable drag so the debug camera isn't annoying to use
	if self.is_debug_freeform:
		self.drag_margin_h_enabled = false
		self.drag_margin_v_enabled = false
	else:
		self.drag_margin_h_enabled = true
		self.drag_margin_v_enabled = true
	
func getCameraYDisplacement():
	# Determine the displacement required to move the camera so that there's N number of tiles visible below the target
	var gameHeight = ProjectSettings.get_setting("display/window/size/height")
	var collisionShape = target.get_node("CollisionShape2D") as CollisionShape2D
	var distanceFromBottom = NUM_TILES_FROM_BOTTOM_OF_VIEWPORT * Globals.TILE_SIZE
	var playerDisplace = collisionShape.transform.y.y + (collisionShape.shape.extents.y)
	return (gameHeight / 2) - distanceFromBottom - playerDisplace
	

