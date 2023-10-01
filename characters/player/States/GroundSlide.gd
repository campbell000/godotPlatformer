extends State
class_name GroundSlide


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var timeElapsed = 0

var ATTACK_DURATION = 0.55

var SPEED_MULTIPLIER = 1.42

var isSlidingRight = false

var startingVel = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called when a state is entered for the first time. Init stuff here
func start(player: Player):
	self.timeElapsed = 0
	player.animatedSprite.play("Slide")
	player.groundSlideHitbox.disabled = false;
	player.slideInteractiveCollisionShape.disabled = false
	player.slideCollisionShape.disabled = false
	player.toggleNormalCollisionBoxes(false)
	
	if abs(player.velocity.x) <= Physics.MAX_RUN_SPEED:
		player.velocity.x = player.velocity.x * SPEED_MULTIPLIER
		player.isBreakingSpeedLimit = true
		
	self.isSlidingRight = player.velocity.x >= 0
	self.startingVel = player.velocity.x
	
# Called ON the first time a state is entered, as well as every physics frame that the state is active
func update(player: Player, delta: float):
	Common.handleGroundMovement(player, delta, func speedModifier(x):
		# If accelerating BACKWARDS, don't allow them to turn so sharply. Sliding should be a commitment
		if self.isSlidingRight && x['xAccel'] < 0:
			x['xAccel'] = x['xAccel'] * 0.25
		elif !self.isSlidingRight && x['xAccel'] > 0:
			x['xAccel'] = x['xAccel'] * 0.25
			
		# DOn't allow speed ups
		x['maxSpeed'] = abs(self.startingVel)
		
		# Make turning around a better drag than pressing no buttons
		x['drag'] = Physics.BREAKING_SPEED_DRAG
		
		return x
	)
	
	self.timeElapsed += delta	
	self.transitionToNewStateIfNecessary(player, delta)
		
func transitionToNewStateIfNecessary(player, delta):
	# If we're not on the floor, and we're not jumping, then we're falling, no matter what
	if !player.is_on_floor() && player.state != player.get_node("States/Jumping"):
		player.transition_to_state(player.get_node("States/SlideFall"))
	else:
		# otherwise, if we're jumping (or the user buffered a jump), transition
		if player.justJumpedOrBufferedAJump():
			var jump = player.get_node("States/Jumping")
			jump.cameFromSlide = true
			player.transition_to_state(player.get_node("States/Jumping"))
	if self.timeElapsed >= ATTACK_DURATION:
		player.transition_to_state(player.get_node("States/OnGround"))
	
func _on_AnimationPlayer_animation_finished(anim):
	pass

func end(player: Player):
	super.end(player)
	player.groundSlideHitbox.disabled = true;
	player.slideInteractiveCollisionShape.disabled = true
	player.slideCollisionShape.disabled = true
	player.toggleNormalCollisionBoxes(true)

func getName():
	return "Ground Attack"
