extends State
class_name Jumping

var isHighJumping = true
var firstUpdate = false
var canceledEarly = false
var nestedState = null

func start(player: Player):
	# Set correct states
	self.isHighJumping = true
	player.storedWallJumpSpeed = 0
	player.bufferTimer = 0
	player.velocity.y = -Common.JUMP_FORCE
	self.firstUpdate = true
	
	# play animations
	player.animatedSprite.play("Jump")
	
func update(player: Player, delta: float):
	var currentGrav = Common.handleJumpLogic(player, self)
	Common.handleAirMovement(player, delta, currentGrav)
	
	if player.velocity.y >= 0:
		player.animatedSprite.play("Fall")
	
	self.transitionToNewStateIfNecessary(player, delta)
	self.transitionInternalState(player, delta)
	
	
	self.firstUpdate = false

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
		elif Common.shouldAirAttack(player):
			if Input.is_action_pressed('move_up'):
				var state = player.get_node("States/UpAirAttack")
				player.transition_to_state(state)
				Common.transferJumpState(self, state)
			else: 
				var state = player.get_node("States/AirAttack")
				player.transition_to_state(state)
				Common.transferJumpState(self, state)

func transitionInternalState(player: Player, delta):
	if self.nestedState == null:
		if Common.shouldAirAttack(player):
			self.nestedState = player.get_node("States/AirAttack")
			self.nestedS


func end(player):
	self.isHighJumping = false
	self.canceledEarly = false
	
func getName():
	return "Jumping"
