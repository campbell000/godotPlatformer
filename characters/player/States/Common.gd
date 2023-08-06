extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var SPEED_BOOST_VEL = 500

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

static func handleGroundMovement(player, delta: float):
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
		
	Physics.process_movement(player, delta, {"xAccel": accel, "drag": dragVal, "gravity": gravity, "maxSpeed": maxRunSpeed})
	
	Common.setBreakingSpeedLimitFlag(player)
			
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
