extends Character
class_name Player

# The length of the buffer window. In other words, the maximum amount of time a user can press the jump button
# early
const JUMP_BUFFER_TIME_WINDOW = 0.07

var bufferTimer = 0.0
var velocity: Vector2 = Vector2()
var prevVector: Vector2 = Vector2()
var isMoving: bool = false
var isFacingForward: bool = true

# Scene Nodes
onready var animatedSprite = $AnimatedSprite
onready var collisionShape = $CollisionShape2D
onready var leftRaycast = $RaycastContainer/LeftRaycast
onready var rightRaycast = $RaycastContainer/RightRaycast
onready var debugStateLabel = $DebugStateLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	self.state = self.get_node("States/OnGround")
	self.state.start(self)
	pass # Replace with function body.

func _process(delta):
	pass
		
# All of this is placeholder physics logic
func _physics_process(delta):
	# First, handle the inputs. 
	self.state.update(self, delta)
	self._handlePlayerStateAfterMove(delta)
	self.debugStateLabel.text = self.state.getName()

func _handlePlayerStateAfterMove(delta):
	if self.bufferTimer > 0:
		self.bufferTimer -= delta
		
	if Input.is_action_pressed("move_left"):
		self.isFacingForward = false
	elif Input.is_action_pressed("move_right"):
		self.isFacingForward = true
		
	if !self.isFacingForward:
		self.animatedSprite.flip_h = true
	elif self.isFacingForward:
		self.animatedSprite.flip_h = false
		
func collidedWithLeftWall():
	return self.leftRaycast.is_colliding()
	
func collidedWithRightWall():
	return self.rightRaycast.is_colliding()
