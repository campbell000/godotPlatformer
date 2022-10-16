extends Character
class_name Player

# The length of the buffer window. In other words, the maximum amount of time a user can press the jump button
# early
const JUMP_BUFFER_TIME_WINDOW = 0.08333

var bufferTimer = 0.0
var velocity: Vector2 = Vector2()
var prevVector: Vector2 = Vector2()
var isMoving: bool = false
var isFacingForward: bool = true
var allowedUnlimitedSpeed: bool = false
var isReturningToNormalSpeed: bool = false
var currentDirection = null
var isMaintainingInertia: bool = false
var isGainingInertia: bool = false
var maintainInertiaDrag: float = Physics.INITIAL_MAINTAIN_INERTIA_DRAG
var debugAccel = 0
const INERTIA_DRAG_INCREASE_PER_MS = 0.5

# Scene Nodes
onready var animatedSprite = $AnimatedSprite
onready var sprite = $Sprite
onready var collisionShape = $CollisionShape2D
onready var leftRaycast: RayCast2D = $RaycastContainer/LeftRaycast
onready var rightRaycast: RayCast2D = $RaycastContainer/RightRaycast
onready var debugStateLabel = $DebugStateLabel
onready var debugHUD = $CanvasLayer/DebugHUD

# Called when the node enters the scene tree for the first time.
func _ready():
	self.state = self.get_node("States/OnGround")
	self.sprite = $Sprite
	self.state.start(self)
	pass # Replace with function body.

func _process(delta):
	pass
		
# All of this is placeholder physics logic
func _physics_process(delta):
	# If the user JUST pressed jump, set the buffer timer
	if Input.is_action_just_pressed("jump"):
		self.bufferTimer = JUMP_BUFFER_TIME_WINDOW
		
	if Input.is_action_just_pressed("move_left"):
		self.currentDirection = "move_left"
	elif Input.is_action_just_pressed("move_right"):
		self.currentDirection = "move_right"

	# First, handle the inputs. 
	self.state.update(self, delta)
	self._handlePlayerStateAfterMove(delta)
	self.debugStateLabel.text = self.state.getName()+"\n"+str(self.velocity.x)
	self.handleDebugHUD()
	
func handleDebugHUD():
	var s = "Maintaining: "+str(self.isMaintainingInertia)
	s += "\nGaining: "+str(self.isGainingInertia)
	s += "\nSpeed: "+str(round(self.velocity.x))
	s += "\nAccel: "+str(round(debugAccel))
	s += "\nDrag: "+str(self.maintainInertiaDrag)
	self.debugHUD.text = s
	
func justJumpedOrBufferedAJump():
	return Input.is_action_just_pressed("jump") || self.bufferTimer > 0

func _handlePlayerStateAfterMove(delta):
	if self.bufferTimer > 0:
		self.bufferTimer -= delta
		
	if Input.is_action_pressed("move_left") && self.velocity.x <= 0:
		self.sprite.flip_h = true
	elif Input.is_action_pressed("move_right") && self.velocity.x >= 0:
		self.sprite.flip_h = false
		
	if self.is_on_floor():
		self.sprite.rotation = get_floor_normal().angle() + PI/2
	else:
		self.sprite.rotation = 0
		
	if self.velocity.x <= Physics.MAX_RUN_SPEED and self.velocity.x >= -Physics.MAX_RUN_SPEED:
		self.isMaintainingInertia = false
		self.maintainInertiaDrag = Physics.INITIAL_MAINTAIN_INERTIA_DRAG
		
	if self.isMaintainingInertia and !self.isGainingInertia:
		self.maintainInertiaDrag = self.maintainInertiaDrag * (1 + (INERTIA_DRAG_INCREASE_PER_MS * delta))
		
func collidedWithLeftWall():
	return self._collidedWithWall(self.leftRaycast, "left")
			
func collidedWithRightWall():
	return self._collidedWithWall(self.rightRaycast, "right")
			
func _collidedWithWall(raycast: RayCast2D, label):
	# IMPORTANT! NEED TO ENSURE TILEMAP IS NOT OFFSET IN THE ROOT NODE, OTHERWISE WORLD_TO_MAP RETURNS WRONG CELLS!!!!!!!!!
	var hit_collider = raycast.get_collider()
	if hit_collider is TileMap:
		var globalCollisionPoint = raycast.get_collision_point()
		var tile_pos = hit_collider.world_to_map(globalCollisionPoint)
		var _tile_coords = hit_collider.get_cell_autotile_coord(tile_pos[0], tile_pos[1])
		var int_tile_coords = [int(_tile_coords[0]), int(_tile_coords[1])]
		if Physics.INVALID_WALL_JUMP_CELLS.has(int_tile_coords[0]) and Physics.INVALID_WALL_JUMP_CELLS[int_tile_coords[0]].has(int_tile_coords[1]):
			return false
		else: 
			print("HIT: "+label)
			return true

func isRunningDownHill():
	if self.is_on_floor():
		var angleOfSlope = get_floor_normal().angle() + PI/2
		if angleOfSlope > 0 and self.velocity.x > 0:
			return true
		elif angleOfSlope < -0.01 and self.velocity.x < 0:
			return true
		else:
			return false
	else:
		return false
	
func getXAccel():
	var accel = 0
	var multiplier = 0
	if self.getDeconflictedDirectionalInput() == "move_left":
		multiplier = -1
	elif self.getDeconflictedDirectionalInput() == "move_right":
		multiplier = 1
		
	if self.is_on_floor():
		if (multiplier == -1 and self.velocity.x > Physics.MAX_RUN_SPEED) || (multiplier == 1 and self.velocity.x < -Physics.MAX_RUN_SPEED):
			accel = Physics.TURN_AROUND_GROUND_ACCEL
		else:
			if abs(self.velocity.x) < Physics.MAX_RUN_SPEED:
				accel = Physics.START_RUN_ACCEL
			else:
				accel = Physics.MAINTAIN_RUN_ACCEL
	else:
		if (multiplier == -1 and self.velocity.x > Physics.MAX_RUN_SPEED) || (multiplier == 1 and self.velocity.x < -Physics.MAX_RUN_SPEED):
			accel = Physics.TURN_AROUND_AIR_ACCEL
		else:
			if abs(self.velocity.x) < Physics.MAX_RUN_SPEED:
				accel = Physics.AIR_ACCEL
			else:
				accel = Physics.MAINTAIN_RUN_ACCEL
			
	var finalAccel = accel * multiplier
	self.debugAccel = finalAccel
	return finalAccel
	
func isOnSlope():
	return self.is_on_floor() and self.get_floor_normal().dot(Vector2.UP) != 1
	
# Returns the direction (left or right) that is currently being pressed. If both buttons are being held
# at the same time, then the most recent one wins (i.e. if a player is moving left but then switches right,
# but they hold left for a split second, we want to immediately start moving right)
func getDeconflictedDirectionalInput():
	if self.currentDirection != null && Input.is_action_pressed(self.currentDirection):
		return self.currentDirection
	elif Input.is_action_pressed("move_left"):
		return "move_left"
	elif Input.is_action_pressed("move_right"):
		return "move_right"
