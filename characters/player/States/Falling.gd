extends State
class_name Falling

const LEDGE_GRACE_PERIOD = 0.05

var ledgeGraceTimer = 0
var cameFromGround = false

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	set_physics_process(false)
	set_process_input(false)

# Called when a state is entered for the first time. Init stuff here
func start(player: Player):
	player.animatedSprite.play("Fall")
	player.storedWallJumpSpeed = 0
	self.ledgeGraceTimer = LEDGE_GRACE_PERIOD
	self.cameFromGround = false

	# Start with a null inner state. Wait until we need to transition to attacks or something.
	super.transitionToNestedState(player, player.get_node("States/NullNestedJumpState"), 1.0)
	
# Called ON the first time a state is entered, as well as every physics frame that the state is active
func update(player: Player, delta: float):
	# Allow limited acceleration if holding left or right in the air
	# Keep track of the ledge grace time.
	if self.ledgeGraceTimer >= 0:
		self.ledgeGraceTimer -= delta
		
	self.currentInnerState.update(player, self, delta)

func input_update(player, event):
	if self.cameFromGround && self.ledgeGraceTimer > 0:
		# Otherwise, if we still have some time in our ledge grace timer, and teh user pressed jump, then allow a jump
		if Input.is_action_just_pressed("jump"):
			player.transition_to_state(player.get_node("States/Jumping"))
	else:
		# Otherwise, if we're colliding against a wall and the user is holding direction towards the wall, go to wall drag
		if Common.shouldWallDrag(player):
			player.transition_to_state(player.get_node("States/WallDragging"))
			
func physics_update(player, delta):
	Common.handleAirMovement(player, delta)
	if absf(player.velocity.x) > absf(Physics.MAX_RUN_SPEED):
		player.storedWallJumpSpeed = player.velocity.x
		
	if player.is_on_floor():
		var groundState = player.get_node("States/OnGround") as State
		player.transition_to_state(groundState)
			
func getName():
	return "Falling"
