extends State
class_name InCutscene

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	set_physics_process(false)
	set_process_input(false)

# Called when a state is entered for the first time. Init stuff here
func start(player: Player):
	pass
	
func physics_update(player: Player, delta: float):
	# Put into common because it's shared with GroundAttack
	Physics.process_movement(player, delta, {
		"drag": 99999
	})
	
func process_update(player: Player, delta: float):
	player.animatedSprite.play("Idle")

func getName():
	return "InCutscene"
