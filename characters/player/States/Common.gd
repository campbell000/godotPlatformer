extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var SPEED_BOOST_VEL = 500


# Gravity when the player is holding the JUMP button
const JUMP_GRAVITY: float = 300.0

const CANCELLED_JUMP_GRAVITY: float = 1325.0

# Initial velocity of the player's jump
const JUMP_FORCE: float = 215.0

const DOWN_SNAP = Vector2(0, -32)

# Once the player's vel is at or over this limit (i.e. towards the apex of their jump), regular GRAVITY gets applied
# Primarily used so that the jump isn't as floaty looking. Also, increase this value so that the player needs to
# hold down the jump button for less time (annoying to have to hold down the button for the ENTIRE duration of the jump)
const JUMP_VEL_LIMIT = -120.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

static func shouldWallJump(player):
	return player.justJumpedOrBufferedAJump() && player.justJumpedOrBufferedAJump() && (player.collidedWithLeftWall() || player.collidedWithRightWall())
	
static func shouldWallDrag(player, disregardVelocity=false):
	# Otherwise, if we're colliding against a wall and the user is holding direction towards the wall, go to wall drag
	var wallDragState = player.get_node("States/WallDragging") as State
	return ((player.velocity.y >= 0 or disregardVelocity)
		and ((player.collidedWithLeftWall() && player.getDeconflictedDirectionalInput() == "move_left")
			or (player.collidedWithRightWall() && player.getDeconflictedDirectionalInput() == "move_right")))
			
static func shouldAirAttack(player):
	return Input.is_action_just_pressed("attack")

static func handleGroundMovement(player, delta: float, speedModifierFunc = null):
	# Determine if we should apply run acceleration. Do it if teh user is pressing left or right
	var accel = player.getXAccel()
		
	# Drag if the player is doing nothing
	var playerIsNotTouchingMovementControls = accel == 0
	var dragVal = Physics.GROUND_DRAG if playerIsNotTouchingMovementControls else 0;
	if dragVal != 0 and player.isBreakingSpeedLimit:
		dragVal = 3
	
	# If we're on the ground AND running down a slope, allow the max speed to go higher
	var maxRunSpeed = Physics.MAX_RUN_SPEED
	var gravity = Physics.GRAVITY
	
	if player.isRunningDownHill() and !playerIsNotTouchingMovementControls:
		maxRunSpeed = Physics.MAX_RUN_SPEED_SLOPE
		dragVal = Physics.GAIN_INERTIA_DRAG
		player.isBreakingSpeedLimit = true
	elif player.isBreakingSpeedLimit and !playerIsNotTouchingMovementControls:
		dragVal = Physics.BREAKING_SPEED_DRAG
		
	# Above all, is player is in a speed boost, set constant velocity
	if player.speedBoostDir != 0:
		player.velocity.x = Common.SPEED_BOOST_VEL * player.speedBoostDir
		player.isBreakingSpeedLimit = true
		
	var speedParams = {"xAccel": accel, "drag": dragVal, "gravity": gravity, "maxSpeed": maxRunSpeed}
	if speedModifierFunc != null:
		speedParams = speedModifierFunc.call(speedParams)
		
	Physics.process_movement(player, delta, speedParams)
	
	Common.setBreakingSpeedLimitFlag(player)

static func transferJumpState(oldState, newState):
	newState.isHighJumping = oldState.isHighJumping
	newState.canceledEarly = oldState.canceledEarly
	

static func handleJumpLogic(player, state):
	# If the user is holding down the jump button, then do a high jump for this frame.
	# If they aren't, then don't allow a high jump for the rest of the jump, even if the
	# user holds down jump again
	if absf(player.velocity.x) > absf(Physics.MAX_RUN_SPEED):
		player.storedWallJumpSpeed = player.velocity.x
	var currentGrav = Physics.GRAVITY
	if state.isHighJumping:
		if !Input.is_action_pressed("jump"):
			state.isHighJumping = false
			if player.velocity.y < JUMP_VEL_LIMIT:
				state.canceledEarly = true
			
	# Stop high jumping at a certain point, no matter what. Makes it so the user doesn't need to hold
	# jump for the entirety of the jump (which would be annoying)
	if player.velocity.y >= JUMP_VEL_LIMIT:
		state.isHighJumping = false
			
	# If we ARE high high jumping, apply a lesser gravity to the player
	if state.isHighJumping and player.velocity.y < JUMP_VEL_LIMIT:
		currentGrav = JUMP_GRAVITY
		
	# If we ARENT high jumping and the player canceled early, apply a heavier gravity
	if !state.isHighJumping and player.velocity.y < 0 and state.canceledEarly:
		currentGrav = CANCELLED_JUMP_GRAVITY
	
	return currentGrav

static func handleAirMovement(player: Player, delta: float, gravity: float = Physics.GRAVITY, options = {}):
	var accel = options.get("accel", 696969696)
	if accel == 696969696:
		accel = player.getXAccel()
		
	var dragVal = options.get("drag", 696969696)
	if dragVal == 696969696:
		dragVal = Physics.AIR_DRAG if accel == 0 else 0
	
	if player.isBreakingSpeedLimit:
		if accel > 0 && player.velocity.x > 0:
			accel = 0
			dragVal = Physics.AIR_BREAKING_SPEED_DRAG
		elif accel < 0 && player.velocity.x < 0:
			accel = 0
			dragVal = Physics.AIR_BREAKING_SPEED_DRAG
			
	Physics.process_movement(player, delta, {"xAccel": accel, "drag": dragVal, "gravity": gravity, "maxSpeed": Physics.MAX_RUN_SPEED})
	Common.setBreakingSpeedLimitFlag(player)
	
static func setBreakingSpeedLimitFlag(player):
	if player.isBreakingSpeedLimit:
		if player.velocity.x <= Physics.MAX_RUN_SPEED and player.velocity.x >= -Physics.MAX_RUN_SPEED:
			player.isBreakingSpeedLimit = false
