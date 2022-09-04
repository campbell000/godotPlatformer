extends Camera2D

const DEBUG_CAMERA_SPEED = 300

# The number of tiles that should appear BELOW the player when standing. 2 is chosen
# because that's kinda how much space SMW has below the player
const NUM_TILES_FROM_BOTTOM_OF_VIEWPORT = 2
const NUM_TILES_FROM_CENTER = 4
const x_offset = 40
const CAMERA_OFFSET_SPEED = 400
const LINE_DISTANCE = 30
var player
var target
var is_debug_freeform: bool = false
var isTrackingForwardMotion = true
var GAME_WIDTH: float
var NUMBER_OF_LINES: float = 10.0
var LINE_UNIT_DISTANCE: float

# Called when the node enters the scene tree for the first time.
func _ready():
	self.player = get_node(Globals.PLAYER_NODE_PATH)
	self.target = self.player
	self.position.x = self.target.position.x
	self.GAME_WIDTH = ProjectSettings.get_setting("display/window/size/width")
	self.LINE_UNIT_DISTANCE = self.GAME_WIDTH / self.NUMBER_OF_LINES

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# If we're not doing debug camera stuff, track the target
	self.handleDebugCamera(delta)
	if self.target != null:
		var targetPos = self.target.position
		if !is_debug_freeform:
			# TODO: Platform snap? Slow following vertical movement (a la cave story?)
			self.position.y = target.position.y# - getCameraYDisplacement()
			
			# For x position for the player, use the "four line" approach. https://old.reddit.com/r/gamedev/comments/jqz8fv/4_line_trick_for_handling_camera_offset_in_2d/
			# We do this so that we can give the player a little more of a "lookahead" when running.
			# For this, we need to base the decision on the player's position in the viewport, not their "world" position (since that changes when the camera moves)
			var playerScreenXPos = self.target.get_global_transform_with_canvas().origin.x
			if self.target == self.player:
				var previousIsTrackingForwardMotion = self.isTrackingForwardMotion
				var lineOnePos = self.LINE_UNIT_DISTANCE * 3
				var lineTwoPos = self.LINE_UNIT_DISTANCE * 4.5
				var lineThreePos = self.LINE_UNIT_DISTANCE * 5.5
				var lineFourPos = self.LINE_UNIT_DISTANCE * 7
				
				# Determine if we need to reorient the camera for forward or backwards running
				if playerScreenXPos <= lineOnePos:
					self.isTrackingForwardMotion = false
				elif playerScreenXPos >= lineFourPos:
					self.isTrackingForwardMotion = true
						
				# If the curerent camera position is BEHIND the first line (which is LEFT of the player),
				# then start following the THIRD line (shifts the camera forward).
				# 
				# If the camera pos is AHEAD of the fourth line, then start following the second line 
				# (shifts the camera left). 
				#
				# But don't SNAP to the desired line. Do so in increments so that it's a smoother animation
				if self.isTrackingForwardMotion and playerScreenXPos >= lineTwoPos:
					self.position.x += CAMERA_OFFSET_SPEED * delta
					if (playerScreenXPos - (CAMERA_OFFSET_SPEED * delta)) <= lineTwoPos:
						self.position.x = self.target.position.x + (self.LINE_UNIT_DISTANCE * 0.5)
				elif !self.isTrackingForwardMotion and playerScreenXPos <= lineThreePos: 
					self.position.x -= CAMERA_OFFSET_SPEED * delta
					if (playerScreenXPos + (CAMERA_OFFSET_SPEED * delta)) >= lineThreePos:
						self.position.x = self.target.position.x - (self.LINE_UNIT_DISTANCE * 0.5)
			else:
				self.position.x = targetPos.x
		
func handleDebugCamera(delta):
	if Input.is_action_pressed("camera_down"):
		self.is_debug_freeform = true
		self.position.y += DEBUG_CAMERA_SPEED * delta
	if Input.is_action_pressed("camera_up"):
		self.is_debug_freeform = true
		self.position.y -= DEBUG_CAMERA_SPEED * delta
	if Input.is_action_pressed("camera_left"):
		self.is_debug_freeform = true
		self.position.x -= DEBUG_CAMERA_SPEED * delta
	if Input.is_action_pressed("camera_right"):
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
	print(gameHeight)
	var collisionShape = target.get_node("CollisionShape2D") as CollisionShape2D
	var distanceFromBottom = NUM_TILES_FROM_BOTTOM_OF_VIEWPORT * Globals.TILE_SIZE
	var playerDisplace = collisionShape.transform.y.y + (collisionShape.shape.extents.y)
	return (gameHeight / 2) - distanceFromBottom - playerDisplace

