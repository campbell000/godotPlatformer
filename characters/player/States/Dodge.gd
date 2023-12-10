extends State
class_name Dodge

var timeElapsed
var DURATION = 0.4
const AIRDODGE_FORCE = Physics.MAX_RUN_SPEED
var blinkTime = 0.03333
var NO_GRAV_DURATION = 0.134

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	set_physics_process(false)
	set_process_input(false)
	
# Called when a state is entered for the first time. Init stuff here
func start(player: Player):
	player.canAirdodge = false
	self.timeElapsed = 0
	player.animatedSprite.play("Dodge")
	player.interactiveCollisionShape.disabled = true
	
	
	var xDir = Input.get_axis("move_left", "move_right")
	var yDir = Input.get_axis("move_up", "move_down")
	if xDir != 0 or yDir != 0:
		var angle = atan2(yDir, xDir)
		var xImpulse = cos(angle) * AIRDODGE_FORCE
		var yImpulse = sin(angle) * AIRDODGE_FORCE
		player.velocity = Vector2(xImpulse, yImpulse)
	
func process_update(player: Player, delta: float):
	player.sprite.visible = int(self.timeElapsed / self.blinkTime) % 2 == 0
		
	
# Called ON the first time a state is entered, as well as every physics frame that the state is active
func physics_update(player: Player, delta: float):
	self.timeElapsed += delta
	
	var grav = Physics.GRAVITY
	var drag = Physics.AIR_DRAG
	if self.timeElapsed <= NO_GRAV_DURATION:
		grav = 0
		drag = 0
	
	# After the initial impulse, don't allow control over the direction
	var options = {"accel": 0, "drag": drag}
	Common.handleAirMovement(self, player, delta, grav, options)
	
	self.transitionToNewStateIfNecessary(player, delta)

func transitionToNewStateIfNecessary(player, delta):
	if player.is_on_floor():
		var groundState = player.get_node("States/OnGround") as State
		player.transition_to_state(groundState)
	elif self.timeElapsed >= DURATION:
		player.transition_to_state(player.get_node("States/Falling"))
	
func end(player):
	super.end(player)
	player.sprite.visible = true
	player.interactiveCollisionShape.disabled = false
	
func getName():
	return "Dodge"
