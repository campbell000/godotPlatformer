extends Area2D


export var speed : int = 100
export var moveDist : int = 100
onready var startX : float = position.x
onready var targetX : float = position.x + moveDist

func _physics_process (delta):
	
	# move to the "targetX" position
	position.x = move_to(position.x, targetX, speed * delta)
	# if we're at our target, move in the other direction
	if position.x == targetX:
		if targetX == startX:
			targetX = position.x + moveDist
		else:
			targetX = startX

func move_to (current, to, step):
	var new = current
	# are we moving positive?
	if new < to:
		new += step
		if new > to:
			new = to
	# are we moving negative?
	else:
		new -= step
		if new < to:
			new = to
	return new
