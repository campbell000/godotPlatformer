extends State
class_name Falling

# Rate at which the player gains speed in the air. Slower so that jumps are more committal
const AIR_ACCEL: float = 530.0

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
	self.ledgeGraceTimer = LEDGE_GRACE_PERIOD
	self.cameFromGround = false
	
# Called ON the first time a state is entered, as well as every physics frame that the state is active
func update(player: Player, delta: float):
	# Allow limited acceleration if holding left or right in the air
	var accel = player.getXAccel()
		
	var dragVal = Physics.AIR_DRAG if accel == 0 else 0
	
	Physics.process_movement(player, delta, {"xAccel": accel, "noMovementDrag": dragVal, "gravity": Physics.GRAVITY, "maxSpeed": Physics.MAX_RUN_SPEED, "snapVector": Physics.DOWN_SNAP})
	self.transitionToNewStateIfNecessary(player, delta)
	
	# Keep track of the ledge grace time.
	if self.ledgeGraceTimer >= 0:
		self.ledgeGraceTimer -= delta
		
func transitionToNewStateIfNecessary(player, delta):
	# If we're suddenly on the floor, transition to ground state
	if player.is_on_floor():
		var groundState = player.get_node("States/OnGround") as State
		player.transition_to_state(groundState)
	elif self.cameFromGround && self.ledgeGraceTimer > 0:
		# Otherwise, if we still have some time in our ledge grace timer, and teh user pressed jump, then allow a jump
		if Input.is_action_just_pressed("jump"):
			print("Coyote Jump!!!!!")
			player.animatedSprite.play("Jump")
			player.transition_to_state(player.get_node("States/Jumping"))
	else:
		# Otherwise, if we're colliding against a wall and the user is holding direction towards the wall, go to wall drag
		var wallDragState = player.get_node("States/WallDragging") as State
		if (player.collidedWithLeftWall() && player.getDeconflictedDirectionalInput() == "move_left") || (player.collidedWithRightWall() && player.getDeconflictedDirectionalInput() == "move_right"):
			player.transition_to_state(wallDragState)
			
func getName():
	return "Falling"
