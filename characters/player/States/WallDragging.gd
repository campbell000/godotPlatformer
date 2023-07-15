extends State
class_name WallDragging

const WALL_DRAG = 75.0

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	set_physics_process(false)
	set_process_input(false)

# Called when a state is entered for the first time. Init stuff here
func start(player: Player):
	player.animatedSprite.play("WallSlide")
	pass
	
# Called ON the first time a state is entered, as well as every physics frame that the state is active
func update(player: Player, delta: float):
	# Apply a constant downward velocity
	player.velocity.y = WALL_DRAG
	player.set_velocity(player.velocity)
	# TODOConverter40 looks that snap in Godot 4.0 is float, not vector like in Godot 3 - previous value `Physics.DOWN_SNAP`
	player.set_up_direction(Vector2.UP)
	player.move_and_slide()
	player.velocity = player.velocity
	self.transitionToNewStateIfNeeded(player, delta)
	
func transitionToNewStateIfNeeded(player, delta):
	# If we're on the ground, stop what we're doing and go to the ground state
	if player.is_on_floor():
		player.transition_to_state(player.get_node("States/OnGround"))
	else:
		# If we're no longer colliding with a wall, then we're now falling
		var collidingLeft = player.collidedWithLeftWall()
		var collidingRight = player.collidedWithRightWall()
		if (!collidingLeft && !collidingRight):
			player.transition_to_state(player.get_node("States/Falling"))
		else:
			# If jumping, then wall jump
			if Input.is_action_just_pressed("jump"):
				player.transition_to_state(player.get_node("States/WallJumping"))
			elif (collidingRight and player.getDeconflictedDirectionalInput() == "move_left") || (collidingLeft and player.getDeconflictedDirectionalInput() == "move_right"):
				# If the user is moving AWAY from the wall, then force a fall
				player.transition_to_state(player.get_node("States/Falling"))
	
func getName():
	return "WallDrag"
