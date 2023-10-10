extends State
class_name Jumping

var isHighJumping = true
var firstUpdate = false
var canceledEarly = false
var cameFromSlide = false
var currGrav = Common.JUMP_GRAVITY

func _ready():
	set_process(false)
	set_physics_process(false)
	set_process_input(false)

func start(player: Player):
	# Set correct states
	self.isHighJumping = true
	player.storedWallJumpSpeed = 0
	player.bufferTimer = 0
	if self.cameFromSlide:
		player.velocity.y = Physics.SLIDE_JUMP_Y_IMPULSE
	else:
		player.velocity.y = -Common.JUMP_FORCE
	self.firstUpdate = true
	
	# Start with a null inner state. Wait until we need to transition to attacks or something.
	super.transitionToNestedState(player, player.get_node("States/NullNestedJumpState"), 1.0)
	
	# play animations
	if self.cameFromSlide:
		player.animatedSprite.play("WallJump")
	else:
		player.animatedSprite.play("Jump")
		
func input_update(player, event):
	if !self.firstUpdate && Input.is_action_just_pressed("jump") && (player.collidedWithLeftWall() || player.collidedWithRightWall()):
		player.transition_to_state(player.get_node("States/WallJumping"))
	elif Common.shouldWallDrag(player):
		# Otherwise, if they've stopped ascending and holding input against a wall, start the wall drag
		player.transition_to_state(player.get_node("States/WallDragging"))
		
	self.currentInnerState.input_update(player, self, event)
		
func update(player: Player, delta: float):
	if player.velocity.y >= 0 && str(self.currentInnerState.get_path()).contains("NullNested"):
		player.animatedSprite.play("Fall")
	self.currentInnerState.update(player, self, delta)

func physics_update(player: Player, delta: float):
	if !self.cameFromSlide:
		self.currGrav = Common.handleJumpLogic(player, self)
	else:
		self.currGrav = Physics.GRAVITY
	Common.handleAirMovement(player, delta, self.currGrav)
	
	if player.is_on_floor():
		var groundState = player.get_node("States/OnGround") as State
		player.transition_to_state(groundState)
	elif !self.firstUpdate && Input.is_action_just_pressed("jump") && (player.collidedWithLeftWall() || player.collidedWithRightWall()):
		player.transition_to_state(player.get_node("States/WallJumping"))
	elif Common.shouldWallDrag(player):
		# Otherwise, if they've stopped ascending and holding input against a wall, start the wall drag
		player.transition_to_state(player.get_node("States/WallDragging"))

	self.firstUpdate = false
	self.currentInnerState.physics_update(player, self, delta)
	
func end(player):
	super.end(player)
	self.isHighJumping = false
	self.canceledEarly = false
	self.cameFromSlide = false

func getName():
	if self.currentInnerState:
		return "Jumping (" + self.currentInnerState.getName()+")"
	else:
		return "Jumping"
