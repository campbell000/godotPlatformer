extends CharacterBody2D
class_name Character


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# The state that the character is currently in
var state: State

func transition_to_state(newStateNode):
	# Clean up the current state, and start the new one
	var newState: State = newStateNode as State
	self.state.end(self)
	newState.start(self)
	self.state = newState
	return newState
