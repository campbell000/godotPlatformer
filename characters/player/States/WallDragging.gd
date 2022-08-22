extends State
class_name WallDragging

const WALL_DRAG = 50.0
const NO_WALL_COLLISON = -1
const LEFT_WALL_COLLISION = 0
const RIGHT_WALL_COLLISION = 1
const WALL_JUMP_Y_VEL_THRESHOLD = -30

const DOWN_SNAP = Vector2(0, -32)

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	set_physics_process(false)
	set_process_input(false)

# Called when a state is entered for the first time. Init stuff here
func start(player: Player):
	pass
	
# Called ON the first time a state is entered, as well as every physics frame that the state is active
func update(player: Player, delta: float):
	player.velocity.y = WALL_DRAG
	player.velocity = player.move_and_slide_with_snap(player.velocity, DOWN_SNAP, Vector2.UP)
	self.transitionToNewStateIfNeeded(player, delta)
	
func transitionToNewStateIfNeeded(player, delta):
	# If we're on the ground, stop what we're doing and go to the ground state
	if player.is_on_floor():
		player.transition_to_state(player.get_node("States/OnGround"))
	else:
		var collidingLeft = player.collidedWithLeftWall()
		var collidingRight = player.collidedWithRightWall()
		if (!collidingLeft && !collidingRight):
			player.transition_to_state(player.get_node("States/Falling"))
		else:
			if Input.is_action_just_pressed("jump"):
				player.transition_to_state(player.get_node("States/WallJumping"))
			elif (collidingRight and Input.is_action_pressed("move_left")) || (collidingLeft and Input.is_action_pressed("move_right")):
				player.transition_to_state(player.get_node("States/Falling"))
	
func getName():
	return "WallDrag"
