extends KinematicBody2D
class_name Character


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# The state that the character is currently in
var state: State

func transition_to_state(newState: State):
	# Clean up the current state, and start the new one
	self.state.exit(self)
	newState.start(self)
	return newState
