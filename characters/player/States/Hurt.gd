extends State
class_name Hurt


var timeElapsed = 0.0
const HURT_IMPULSE = Vector2(-100, -180)
const DURATION = 0.3

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called when a state is entered for the first time. Init stuff here
func start(player: Player):
	self.timeElapsed = 0.0
	player.animatedSprite.play("Fall")
	if player.velocity.x > 0:
		player.velocity = HURT_IMPULSE
	else:
		player.velocity = HURT_IMPULSE * Vector2(-1, 1)
	
# Called ON the first time a state is entered, as well as every physics frame that the state is active
func physics_update(player: Player, delta: float):
	self.timeElapsed += delta
	Physics.process_movement(player, delta, {"xAccel": 0, "drag": 0, "gravity": Physics.GRAVITY})
	self.transitionToNewStateIfNecessary(player, delta)
		
func transitionToNewStateIfNecessary(player, delta):
	if self.timeElapsed >= DURATION:
		if player.is_on_floor():
			var groundState = player.get_node("States/OnGround") as State
			player.transition_to_state(groundState)
		else:
			var groundState = player.get_node("States/Falling") as State
			player.transition_to_state(groundState)
	
func _on_AnimationPlayer_animation_finished(anim):
	pass
	
func end(player: Player):
	player.downairInteractiveCollisionShape.disabled = true
	player.downairHitbox.disabled = true
	player.interactiveCollisionShape.disabled = false
			
func getName():
	return "Hurt"
