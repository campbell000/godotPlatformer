extends State
class_name WallDragging

const WALL_DRAG = 75.0
var dragTimer = 0
var STORED_SPEED_CUTOFF = 0.25

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	set_physics_process(false)
	set_process_input(false)

# Called when a state is entered for the first time. Init stuff here
func start(player: Player):
	player.animatedSprite.play("WallSlide")
	dragTimer = 0
	pass
	
func physics_update(player: Player, delta: float):
	self.dragTimer += delta
	if self.dragTimer > STORED_SPEED_CUTOFF:
		player.storedWallJumpSpeed = 0
		
	# Apply a constant downward velocity
	player.velocity.y = WALL_DRAG
	player.velocity.x = 0
	player.move_and_slide()
	player.velocity = player.velocity
	
	if player.is_on_floor():
		player.transition_to_state(player.get_node("States/OnGround"))
	else:
		# If we're no longer colliding with a wall, then we're now falling
		var collidingLeft = player.collidedWithLeftWall()
		var collidingRight = player.collidedWithRightWall()
		if (!collidingLeft && !collidingRight):
			player.transition_to_state(player.get_node("States/Falling"))
		elif player.jumpWasBuffered():
			player.transition_to_state(player.get_node("States/WallJumping"))
			
func input_update(player, event):
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
