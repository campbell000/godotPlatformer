extends State
class_name Jumping

# Consttant that slows the player down in teh air when they are moving, but not pressing buttons.
# Less drag than on ground
const AIR_DRAG: float = 2.0;

# Rate at which the player gains speed in the air. Slower so that jumps are more committal
const AIR_ACCEL: float = 530.0

# Gravity when the player is holding the JUMP button
const JUMP_GRAVITY: float = 300.0

# Initial velocity of the player's jump
const JUMP_FORCE: float = 215.0

const DOWN_SNAP = Vector2(0, -32)

# Once the player's vel is at or over this limit (i.e. towards the apex of their jump), regular GRAVITY gets applied
# Primarily used so that the jump isn't as floaty looking. Also, increase this value so that the player needs to
# hold down the jump button for less time (annoying to have to hold down the button for the ENTIRE duration of the jump)
const JUMP_VEL_LIMIT = -120.0

var isHighJumping = true
var currentGrav = GRAVITY
var currPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	set_physics_process(false)
	set_process_input(false)

# Called when a state is entered for the first time. Init stuff here
func start(player: Player):
	self.currPlayer = player
	self.isHighJumping = true
	
	if !Input.is_action_just_pressed("jump") && player.bufferTimer > 0:
		player.bufferTimer = 0
		
	player.velocity.y = -JUMP_FORCE
	
# Called ON the first time a state is entered, as well as every physics frame that the state is active
func update(player: Player, delta: float):
	# If the user is currently jumping, but the jump button isn't being held down, stop ascending
	if self.isHighJumping:
		if !Input.is_action_pressed("jump"):
			self.isHighJumping = false
			
	if self.isHighJumping and player.velocity.y < JUMP_VEL_LIMIT:
		self.currentGrav = JUMP_GRAVITY
	else:
		self.currentGrav = GRAVITY
	
	if player.velocity.y >= JUMP_VEL_LIMIT:
		self.isHighJumping = false
	
	###########################################
	# Horizontal Movement
	###########################################
	var shouldDrag = !Input.is_action_pressed("move_left") && !Input.is_action_pressed("move_right")
	if shouldDrag:
		player.velocity.x = player.velocity.x / (1 + (AIR_DRAG * delta))
	else:
		var accel = 0
		if Input.is_action_pressed("move_left"):
			accel = -AIR_ACCEL
		elif Input.is_action_pressed("move_right"):
			accel = AIR_ACCEL
			
		player.velocity.x = player.velocity.x + (accel * delta)
		if player.velocity.x > MAX_RUN_SPEED:
			player.velocity.x = MAX_RUN_SPEED
		if player.velocity.x < -MAX_RUN_SPEED:
			player.velocity.x = -MAX_RUN_SPEED
			
	###########################################
	# Vertical Movement
	###########################################
	#if !self.isFirstFrame:
	player.velocity.y += self.currentGrav * delta
	
	player.velocity = player.move_and_slide_with_snap(player.velocity, DOWN_SNAP, Vector2.UP)
	self.transitionToNewStateIfNecessary(player, delta)

func transitionToNewStateIfNecessary(player, delta):
	if player.is_on_floor():
		var groundState = player.get_node("States/OnGround") as State
		player.transition_to_state(groundState)
		print("Transition to Ground!")
	else:
		if Input.is_action_just_pressed("jump"):
			print(player.collidedWithLeftWall() || player.collidedWithRightWall())
			print(player.velocity)
			print(player.bufferTimer)
			print(Input.is_action_just_pressed("jump"))
			print("=======")
		var goToWallDrag = false
		if (Input.is_action_just_pressed("jump") || player.bufferTimer > 0) && (player.collidedWithLeftWall() || player.collidedWithRightWall()):
			print("Jump => Wall jump[]")
			player.transition_to_state(player.get_node("States/WallJumping"))
		elif player.velocity.y >= 0 && (player.collidedWithLeftWall() && Input.is_action_pressed("move_left") || player.collidedWithRightWall() && Input.is_action_pressed("move_right")):
			print("JUNM => drag")
			var wallDraggingState = player.get_node("States/WallDragging")
			player.transition_to_state(wallDraggingState)
			

func end(player):
	self.isHighJumping = false
	
func getName():
	return "Jumping" + "(" + str(int(currPlayer.velocity.y)) + ")" + "(" + str(self.currentGrav) + ")"
