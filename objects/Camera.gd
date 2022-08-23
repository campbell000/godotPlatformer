extends Camera2D

const DEBUG_CAMERA_SPEED = 300

# The number of tiles that should appear BELOW the player when standing. 2 is chosen
# because that's kinda how much space SMW has below the player
const NUM_TILES_FROM_BOTTOM_OF_VIEWPORT = 2
const NUM_TILES_FROM_CENTER = 4
const x_offset = 40
const CAMERA_OFFSET_SPEED = 4
const LINE_DISTANCE = 30
var player
var target
var isDebugFreeform
var isTrackingForwardMotion = true


# Called when the node enters the scene tree for the first time.
func _ready():
	self.player = get_node(Globals.PLAYER_NODE_PATH)
	self.target = self.player
	self.position.x = self.target.position.x

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# If we're not doing debug camera stuff, track the target
	var targetPos = self.target.position
	self.handleDebugCamera(delta)
	if !isDebugFreeform:
		# TODO: Platform snap? Slow following vertical movement (a la cave story?)
		self.position.y = target.position.y# - getCameraYDisplacement()
		
		# For x position for the player, use the "four line" approach. https://old.reddit.com/r/gamedev/comments/jqz8fv/4_line_trick_for_handling_camera_offset_in_2d/
		# We do this so that we can give the player a little more of a "lookahead" when running
		if self.target == self.player:
			var previousIsTrackingForwardMotion = self.isTrackingForwardMotion
			var lineOnePos = targetPos.x - (2 * LINE_DISTANCE)
			var lineTwoPos = targetPos.x - (0.35 * LINE_DISTANCE)
			var lineThreePos = targetPos.x + (0.35 * LINE_DISTANCE)
			var lineFourPos = targetPos.x + (2 * LINE_DISTANCE)
			
			# Determine if we need to reorient the camera for forward or backwards running
			if self.position.x <= lineOnePos:
				self.isTrackingForwardMotion = true
			elif self.position.x >= lineFourPos:
				self.isTrackingForwardMotion = false
					
			# If the curerent camera position is BEHIND the first line (which is LEFT of the player),
			# then start following the THIRD line (shifts the camera forward).
			# 
			# If the camera pos is AHEAD of the fourth line, then start following the second line 
			# (shifts the camera left). 
			#
			# But don't SNAP to the desired line. Do so in increments so that it's a smoother animation
			if self.isTrackingForwardMotion and self.position.x < lineThreePos:
				self.position.x += CAMERA_OFFSET_SPEED
				if self.position.x > lineThreePos:
					self.position.x = lineThreePos
			elif !self.isTrackingForwardMotion and self.position.x > lineTwoPos: 
				self.position.x -= CAMERA_OFFSET_SPEED
				if self.position.x < lineTwoPos:
					self.position.x = lineTwoPos
		else:
			self.position.x = targetPos.x
		
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
	if self.isDebugFreeform:
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
	
func getCameraXDisplacement():
	var distanceFromPlayer = Globals.TILE_SIZE * NUM_TILES_FROM_CENTER
	return distanceFromPlayer

