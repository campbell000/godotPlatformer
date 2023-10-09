extends Character
class_name Player

# The length of the buffer window. In other words, the maximum amount of time a user can press the jump button
# early
const JUMP_BUFFER_TIME_WINDOW = 0.09333

var bufferTimer = 0.0
var isFacingForward: bool = true
var currentDirection = null
var debugAccel = 0
var storedWallJumpSpeed = 0
var isBreakingSpeedLimit = false
var speedBoostDir = 0
var camera
var wasBounced = false
const INERTIA_DRAG_INCREASE_PER_MS = 0.5

# Scene Nodes
@onready var animatedSprite = $AnimatedSprite2D
@onready var sprite = $Sprite2D
@onready var collisionShape: CollisionShape2D = $CollisionShape2D
@onready var slideCollisionShape: CollisionShape2D = $SlideCollisionShape2D
@onready var downairShape: CollisionShape2D = $DownAirCollisionShape2D
@onready var leftRaycast: RayCast2D = $RaycastContainer/LeftRaycast
@onready var rightRaycast: RayCast2D = $RaycastContainer/RightRaycast
@onready var debugStateLabel = $DebugStateLabel
@onready var debugHUD = $CanvasLayer/DebugHUD

@onready var attackArea2D: Area2D = $AttackArea2D
@onready var playerHurtbox: Area2D = $PlayerHitboxArea2D
@onready var airAttackHitbox: CollisionPolygon2D = $AttackArea2D/AirAttackCollisionShape
@onready var upAirAttackHitbox: CollisionShape2D = $AttackArea2D/UpAirAttackCollisionShape
@onready var groundAttackHitbox: CollisionShape2D = $AttackArea2D/GroundAttackCollisionShape
@onready var groundSlideHitbox: CollisionShape2D = $AttackArea2D/SlideAttackCollisionShape
@onready var downairHitbox: CollisionShape2D = $AttackArea2D/DownAirAttackCollisionShape

@onready var interactiveCollisionShape: CollisionShape2D = $PlayerHitboxArea2D/InteractionCollisionShape
@onready var slideInteractiveCollisionShape: CollisionShape2D = $PlayerHitboxArea2D/SlideInteractionCollisionShape
@onready var downairInteractiveCollisionShape: CollisionShape2D = $PlayerHitboxArea2D/DownAirCollisionShape

# Called when the node enters the scene tree for the first time.
func _ready():
	self.state = self.get_node("States/OnGround")
	self.camera = get_node(Globals.CAMERA_NODE_PATH)
	self.airAttackHitbox.disabled = true
	self.sprite = $Sprite2D
	self.floor_snap_length = 8
	self.state.start(self)
	self.set_floor_stop_on_slope_enabled(true)
	self.slideCollisionShape.disabled = true
	self.slideInteractiveCollisionShape.disabled = true
	self.downairInteractiveCollisionShape.disabled = true
	self.downairHitbox.disabled = true
	pass # Replace with function body.

func _process(delta):
	pass

		
# All of this is placeholder physics logic
func _physics_process(delta):
	# If the user JUST pressed jump, set the buffer timer
	if Input.is_action_just_pressed("jump"):
		self.bufferTimer = JUMP_BUFFER_TIME_WINDOW
		
	# Gather input presses	
	if Input.is_action_just_pressed("move_left"):
		self.currentDirection = "move_left"
	elif Input.is_action_just_pressed("move_right"):
		self.currentDirection = "move_right"

	# First, handle the inputs. 
	self.state.update(self, delta)
	self._handlePlayerStateAfterMove(delta)
	self.debugStateLabel.text = self.state.getName()+"\n"+str(self.velocity.x)
	self.handleDebugHUD()

func toggleNormalCollisionBoxes(isEnabled):
	self.interactiveCollisionShape.disabled = !isEnabled
	self.collisionShape.disabled = !isEnabled

func handleDebugHUD():
	var s = "FPS: "+str(Engine.get_frames_per_second())
	s += "\nSpeed: "+str(round(self.velocity.x))
	s += "\nAccel: "+str(round(debugAccel))
	s += "\nBreaking Speed Limit: "+str(self.isBreakingSpeedLimit)
	s += "\nSpeed Boost Dir: "+str(self.speedBoostDir)
	self.debugHUD.text = s
	
func justJumpedOrBufferedAJump():
	return Input.is_action_just_pressed("jump") || self.bufferTimer > 0

func _handlePlayerStateAfterMove(delta):
	if self.bufferTimer > 0:
		self.bufferTimer -= delta
		
	if Input.is_action_pressed("move_left") && self.velocity.x <= 0:
		self.handleRotation(true)
	elif Input.is_action_pressed("move_right") && self.velocity.x >= 0:
		self.handleRotation(false)
		
	if self.is_on_floor():
		self.sprite.rotation = get_floor_normal().angle() + PI/2
	else:
		self.sprite.rotation = 0

func handleRotation(flip: bool):
	if (flip):
		self.attackArea2D.scale.x = -1
		self.sprite.flip_h = true
		self.playerHurtbox.scale.x = -1
	else:
		self.sprite.flip_h = false
		self.attackArea2D.scale.x = 1
		self.playerHurtbox.scale.x = 1

func collidedWithLeftWall():
	return self._collidedWithWall(self.leftRaycast, "left")
			
func collidedWithRightWall():
	return self._collidedWithWall(self.rightRaycast, "right")
			
func _collidedWithWall(raycast: RayCast2D, label):
	var hit_collider = raycast.get_collider()
	if hit_collider != null and hit_collider is TileMap:
		var globalCollisionPoint = raycast.get_collision_point()
		var tilemap: TileMap = hit_collider
		var cell = tilemap.local_to_map(globalCollisionPoint)
		var data = tilemap.get_cell_tile_data(0, cell)
		return data != null and !data.get_custom_data("cannotWalljump")

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

func takeDamage(damageVal):
	if damageVal == 9999:
		self.position.x = 0
		self.position.y =0
		self.camera.position.x = 0
		self.camera.position.y = 0

func interactiveBodyEntered(body_rid, body, body_shape_index, local_shape_index):
	var coords = body.get_coords_for_body_rid(body_rid)
	var tilemap: TileMap = body
	var data = tilemap.get_cell_tile_data(0, coords)
	
	var d = data.get_custom_data("speedBoostDir")
	if d != null:
		self.speedBoostDir = d

	d = data.get_custom_data("damage")
	if d != null and d != 0:
		self.takeDamage(d)

func interactiveBodyExited(body_rid, body, body_shape_index, local_shape_index):
	var coords = body.get_coords_for_body_rid(body_rid)
	var tilemap: TileMap = body
	var data = tilemap.get_cell_tile_data(0, coords)
	
	var d = data.get_custom_data("speedBoostDir")
	if d != null:
		self.speedBoostDir = 0


func bounce():
	print("Was Bounced")
	self.wasBounced = true
	#if self.state.currentInnerState != null && self.state.currentInnerState is DownAirAttack:
	#	self.transition_to_state(self.get_node("States/Falling"))
	#	self.velocity.y = -self.velocity.y * 1.05
	#	if (self.velocity.y > -320):
	#		self.velocity.y = -320

func areaEntered(area):
	self.takeDamage(9999)
