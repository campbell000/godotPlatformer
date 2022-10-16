extends State
class_name OnGround

var isFirstFrame: bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	set_physics_process(false)
	set_process_input(false)

# Called when a state is entered for the first time. Init stuff here
func start(player: Player):
	self.isFirstFrame = true
	
func update(player: Player, delta: float):
	# Handle run/idle animations
	if Input.is_action_pressed("move_left") || Input.is_action_pressed("move_right"):
		player.animatedSprite.play("Run")
	elif !Input.is_action_pressed("move_left") and !Input.is_action_pressed("move_right"):
		player.animatedSprite.play("Idle")

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
		player.isMaintainingInertia = true
		player.isGainingInertia = true
		maxRunSpeed = Physics.MAX_RUN_SPEED_SLOPE
	elif player.isOnSlope():
		player.isGainingInertia = false
	else:
		player.isGainingInertia = false

	Physics.process_movement(player, delta, {"xAccel": accel, "noMovementDrag": dragVal, "gravity": gravity, "maxSpeed": maxRunSpeed, "snapVector": Physics.DOWN_SNAP, "maintainInertiaDrag": player.maintainInertiaDrag})
	self.transitionToNewStateIfNecessary(player, delta)
	self.isFirstFrame = false

func transitionToNewStateIfNecessary(player, delta):
	# If we're not on the floor, and we're not jumping, then we're falling
	if !player.is_on_floor() && player.state != player.get_node("States/Jumping"):
		var fallingState = player.get_node("States/Falling")
		player.transition_to_state(player.get_node("States/Falling"))
		fallingState.cameFromGround = true
	else:
		# otherwise, if we're jumping (or the user buffered a jump), transition
		if player.justJumpedOrBufferedAJump():
			player.animatedSprite.play("Jump")
			player.transition_to_state(player.get_node("States/Jumping"))

func getName():
	return "OnGround"
	
func end(character):
	character.isGainingInertia = false
