extends State
class_name AirAttack


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var timeElapsed = 0
var isHighJumping = true
var firstUpdate = false
var canceledEarly = false

var ATTACK_DURATION = 0.4


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called when a state is entered for the first time. Init stuff here
func start(player: Player):
	# Set correct states
	self.isHighJumping = true
	self.timeElapsed = 0
	player.animatedSprite.play("AirAttack")
	player.airAttackHitbox.disabled = false;
	
# Called ON the first time a state is entered, as well as every physics frame that the state is active
func update(player: Player, delta: float):
	var currentGrav = Common.handleJumpLogic(player, self)	
	Common.handleAirMovement(player, delta, currentGrav)
	
	self.timeElapsed += delta
	self.transitionToNewStateIfNecessary(player, delta)
		
func transitionToNewStateIfNecessary(player, delta):
	# If on the floor, then transition to ground no matter what
	if player.is_on_floor():
		var groundState = player.get_node("States/OnGround") as State
		player.transition_to_state(groundState)
	else:
		# Otherwise, if we're not on the first frame (otherwise, holding jump and direction against a wall on the ground
		# causes an immediate wall jump), and the user (buffered a) jump and they're against a wall, do the wall jump immediately
		var goToWallDrag = false
		if Common.shouldWallJump(player):
			player.transition_to_state(player.get_node("States/WallJumping"))
		elif Common.shouldWallDrag(player):
			# Otherwise, if they've stopped ascending and holding input against a wall, start the wall drag
			player.transition_to_state(player.get_node("States/WallDragging"))	
		elif self.timeElapsed > ATTACK_DURATION:
			player.transition_to_state(player.get_node("States/Falling"))
	
func _on_AnimationPlayer_animation_finished(anim):
	pass
	
func end(player: Player):
	player.airAttackHitbox.disabled = true;
			
func getName():
	return "Air Attack"
