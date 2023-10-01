extends State
class_name Jumping

var isHighJumping = true
var firstUpdate = false
var canceledEarly = false
var cameFromSlide = false

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
	
func update(player: Player, delta: float):
	if !self.cameFromSlide:
		var currentGrav = Common.handleJumpLogic(player, self)
		Common.handleAirMovement(player, delta, currentGrav)
	else:
		Common.handleAirMovement(player, delta)
	
	if player.velocity.y >= 0 && str(self.currentInnerState.get_path()).contains("NullNested"):
		player.animatedSprite.play("Fall")
	
	self.transitionToNewStateIfNecessary(player, delta)
	self.firstUpdate = false
	
	self.currentInnerState.update(player, self, delta)

func transitionToNewStateIfNecessary(player, delta):
	# If on the floor, then transition to ground no matter what
	if player.is_on_floor():
		var groundState = player.get_node("States/OnGround") as State
		player.transition_to_state(groundState)
	else:
		# Otherwise, if we're not on the first frame (otherwise, holding jump and direction against a wall on the ground
		# causes an immediate wall jump), and the user (buffered a) jump and they're against a wall, do the wall jump immediately
		if !self.firstUpdate && Common.shouldWallJump(player):
			player.transition_to_state(player.get_node("States/WallJumping"))
		elif Common.shouldWallDrag(player):
			# Otherwise, if they've stopped ascending and holding input against a wall, start the wall drag
			player.transition_to_state(player.get_node("States/WallDragging"))

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
