extends State
class_name WallJumping

const WALL_JUMP_FORCE = Vector2(Physics.MAX_RUN_SPEED, -295)

var wallJumpCooldownTimer = 0
const WALL_JUMP_COOLDOWN = (1/60.0) * 6
var controlCooldownTimer = 0
var CONTROL_COOLDOWN = 0.2
var STORED_SPEED_DRAG = 0.9

var wentBelowMaxRun = false

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	set_physics_process(false)
	set_process_input(false)
	
# Called when a state is entered for the first time. Init stuff here
func start(player: Player):
	self.controlCooldownTimer = 0
	player.animatedSprite.play("WallJump")
	self.wallJumpCooldownTimer = WALL_JUMP_COOLDOWN
	player.velocity = self.getWallJumpSpeed(player)
	self.wentBelowMaxRun = true

func getWallJumpSpeed(player):
	var vel = WALL_JUMP_FORCE
	var potentialStoredSpeed = player.storedWallJumpSpeed * STORED_SPEED_DRAG
	if player.collidedWithRightWall():
		vel = WALL_JUMP_FORCE * Vector2(-1, 1)
	if (vel.x < 0 and -potentialStoredSpeed < vel.x) or (vel.x > 0 and -potentialStoredSpeed > vel.x):
		vel.x = -potentialStoredSpeed
		player.isBreakingSpeedLimit = true
	
	return vel
	

# Called ON the first time a state is entered, as well as every physics frame that the state is active
func update(player: Player, delta: float):
	# Allow control in the air when wall jumping, as long as we're out of the cooldown period
	var accel = 0
	var options = {"accel": 0}
	self.controlCooldownTimer += delta
	if self.controlCooldownTimer > CONTROL_COOLDOWN:
		if player.getDeconflictedDirectionalInput() == "move_left":
			options["accel"] = -Physics.AIR_ACCEL
		elif player.getDeconflictedDirectionalInput() == "move_right":
			options["accel"] = Physics.AIR_ACCEL
	else:
		options["drag"] = 0
		
	Common.handleAirMovement(player, delta, Physics.GRAVITY, options)

	self.wallJumpCooldownTimer -= delta
	self.transitionToNewStateIfNecessary(player, delta)
	
func transitionToNewStateIfNecessary(player, delta):
	if player.is_on_floor():
		var groundState = player.get_node("States/OnGround") as State
		player.transition_to_state(groundState)
	elif self.wallJumpCooldownTimer <= 0 and Common.shouldWallDrag(player, true): # Cooldown timer needed so user doesn't go from walljump to drag on first frame
		if (player.collidedWithLeftWall() && player.getDeconflictedDirectionalInput() == "move_left") || (player.collidedWithRightWall() && player.getDeconflictedDirectionalInput() == "move_right"):
			# If we're holding direction towards a wall, go back to wall dragging
			var wallDragState = player.get_node("States/WallDragging")
			player.transition_to_state(wallDragState)
	elif Common.shouldAirAttack(player):
		if Input.is_action_pressed('move_up'):
			var state = player.get_node("States/UpAirAttack")
			player.transition_to_state(state)
			Common.transferJumpState(self, state)
		else: 
			var state = player.get_node("States/AirAttack")
			player.transition_to_state(state)
			Common.transferJumpState(self, state)
	
func getName():
	return "WallJumping"
