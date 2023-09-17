extends State
class_name SlideFall


# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	set_physics_process(false)
	set_process_input(false)

# Called when a state is entered for the first time. Init stuff here
func start(player: Player):
	player.animatedSprite.play("SlideFall")
	player.groundSlideHitbox.disabled = false;
	player.interactiveCollisionShape.disabled = true
	player.collisionShape.disabled = true
	player.slideInteractiveCollisionShape.disabled = false
	player.slideCollisionShape.disabled = false
	
# Called ON the first time a state is entered, as well as every physics frame that the state is active
func update(player: Player, delta: float):
	Common.handleAirMovement(player, delta)
	self.transitionToNewStateIfNecessary(player, delta)
	
func transitionToNewStateIfNecessary(player, delta):
	# If we're suddenly on the floor, transition to ground state
	if player.is_on_floor():
		var groundState = player.get_node("States/OnGround") as State
		player.transition_to_state(groundState)
	elif Input.is_action_just_pressed("jump"):
		var jump = player.get_node("States/Jumping")
		jump.cameFromSlide = true
		player.transition_to_state(jump)
	else:
		# Otherwise, if we're colliding against a wall and the user is holding direction towards the wall, go to wall drag
		if Common.shouldWallDrag(player):
			player.transition_to_state(player.get_node("States/WallDragging"))

func end(player):
	player.groundSlideHitbox.disabled = true;
	player.interactiveCollisionShape.disabled = false
	player.collisionShape.disabled = false
	player.slideInteractiveCollisionShape.disabled = true
	player.slideCollisionShape.disabled = true

func getName():
	return "Falling"
