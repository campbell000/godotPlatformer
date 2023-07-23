extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

static func shouldWallJump(player: Player):
	return player.justJumpedOrBufferedAJump() && player.justJumpedOrBufferedAJump() && (player.collidedWithLeftWall() || player.collidedWithRightWall())
	
static func shouldWallDrag(player: Player, disregardVelocity=false):
	# Otherwise, if we're colliding against a wall and the user is holding direction towards the wall, go to wall drag
	var wallDragState = player.get_node("States/WallDragging") as State
	return ((player.velocity.y >= 0 or disregardVelocity)
		and ((player.collidedWithLeftWall() && player.getDeconflictedDirectionalInput() == "move_left")
			or (player.collidedWithRightWall() && player.getDeconflictedDirectionalInput() == "move_right")))

static func handleGroundMovement(player: Player, delta: float):
	# Determine if we should apply run acceleration. Do it if teh user is pressing left or right
	var accel = player.getXAccel()
		
	# Drag if the player is doing nothing
	var dragVal = Physics.GROUND_DRAG if (accel == 0) else 0;
	if dragVal != 0 and player.isMaintainingInertia:
		dragVal = 3
	
	# If we're on the ground AND running down a slope, allow the max speed to go higher
	var maxRunSpeed = Physics.MAX_RUN_SPEED
	var gravity = Physics.GRAVITY
	
	if player.isRunningDownHill():
		player.isBreakingSpeedLimit = true
		maxRunSpeed = Physics.MAX_RUN_SPEED_SLOPE
	elif player.isOnSlope():
		maxRunSpeed = Physics.MAX_RUN_SPEED_SLOPE
		player.isBreakingSpeedLimit = false
	else:
		player.isGainingInertia = false
	
	
	if player.isGainingInertia:
		player.velocity.x = player.velocity.x / (1 + (GAIN_INERTIA_DRAG * delta))
	elif !player.isGainingInertia and player.isMaintainingInertia:
		var oldV = player.velocity.x
		player.velocity.x = player.velocity.x / (1 + (maintainInertiaDrag * delta))
	
	if player.isRunningDownHill():
		player.isMaintainingInertia = true
		player.isGainingInertia = true
		maxRunSpeed = Physics.MAX_RUN_SPEED_SLOPE
	elif player.isOnSlope():
		player.isGainingInertia = false
	else:
		player.isGainingInertia = false

	Physics.process_movement(player, delta, {"xAccel": accel, "noMovementDrag": dragVal, "gravity": gravity, "maxSpeed": maxRunSpeed, "snapVector": Physics.DOWN_SNAP, "maintainInertiaDrag": player.maintainInertiaDrag})
