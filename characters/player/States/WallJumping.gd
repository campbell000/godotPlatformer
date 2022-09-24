extends State
class_name WallJumping

const WALL_JUMP_FORCE = Vector2(225, -300)

var wallJumpCooldownTimer = 0
const WALL_JUMP_COOLDOWN = (1/60.0) * 3

var wentBelowMaxRun = false

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	set_physics_process(false)
	set_process_input(false)
	
	
# Called when a state is entered for the first time. Init stuff here
func start(player: Player):
	player.animatedSprite.play("WallJump")
	self.wallJumpCooldownTimer = WALL_JUMP_COOLDOWN
	player.velocity = WALL_JUMP_FORCE * Vector2(-1, 1) if player.collidedWithRightWall() else WALL_JUMP_FORCE
	self.wentBelowMaxRun = true
	
# Called ON the first time a state is entered, as well as every physics frame that the state is active
func update(player: Player, delta: float):
	# Allow control in the air when wall jumping
	var accel = 0
	if player.getDeconflictedDirectionalInput() == "move_left":
		accel = -Physics.AIR_ACCEL
	elif player.getDeconflictedDirectionalInput() == "move_right":
		accel = Physics.AIR_ACCEL

	var dragVal = Physics.AIR_DRAG if accel == 0 else 0

	Physics.process_movement(player, delta, {"xAccel": accel, "noMovementDrag": dragVal, "gravity": Physics.GRAVITY, "maxSpeed": Physics.MAX_RUN_SPEED, "snapVector": Physics.DOWN_SNAP})

	self.wallJumpCooldownTimer -= delta
	self.transitionToNewStateIfNecessary(player, delta)
	
func transitionToNewStateIfNecessary(player, delta):
	if player.is_on_floor():
		var groundState = player.get_node("States/OnGround") as State
		player.transition_to_state(groundState)
	elif self.wallJumpCooldownTimer <= 0: # needed so that the user can't immediately go from wall jump back to drag on the first frame of the jump.
		if (player.collidedWithLeftWall() && player.getDeconflictedDirectionalInput() == "move_left") || (player.collidedWithRightWall() && player.getDeconflictedDirectionalInput() == "move_right"):
			# If we're holding direction towards a wall, go back to wall dragging
			var wallDragState = player.get_node("States/WallDragging")
			player.transition_to_state(wallDragState)
	
func getName():
	return "WallJumping"
