extends State
class_name NullState

# Called when a state is entered for the first time. Init stuff here
func start(player: Player):
	pass
	
# Called ON the first time a state is entered, as well as every physics frame that the state is active
func process_update(player: Player, delta: float):
	pass
	
func physics_update(player: Player, delta: float):
	pass
		
func transitionToNewStateIfNecessary(player, delta):
	pass
			
func getName():
	return "NULL STATE"
