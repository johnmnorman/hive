class_name FallingPlayerState extends PlayerMovementState

@export var SPEED: float = 8.5
@export var ACCELERATION : float = 0.02
@export var DECELERATION : float = 0.005
var JUMP_BUFFER_TIME : float = 0.3
#@export var DOUBLE_JUMP_VELOCITY : float = 7

#var DOUBLE_JUMP : bool = false
var INITIAL_JUMP_BUFFER : int
var MIDAIR_JUMP : bool = true

func enter(previous_state) -> void:
	INITIAL_JUMP_BUFFER = 20
	MIDAIR_JUMP = true
	ANIMATION.pause()

	
func exit() -> void:
	pass

	
func physics_update(delta: float) -> void:
	INITIAL_JUMP_BUFFER -= 1
	if INITIAL_JUMP_BUFFER <= 0:
		MIDAIR_JUMP = false
	Global.debug.add_property("JumpBuffer",INITIAL_JUMP_BUFFER,2)
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED,ACCELERATION,DECELERATION)
	PLAYER.update_velocity()
	
	if Input.is_action_just_pressed("jump") and MIDAIR_JUMP == true:
		transition.emit("JumpingPlayerState")
		
	#elif Input.is_action_just_pressed("jump") and DOUBLE_JUMP == false:
		#DOUBLE_JUMP = true
		#PLAYER.velocity.y = DOUBLE_JUMP_VELOCITY
	
	if PLAYER.is_on_floor():
		ANIMATION.play("jump_end")
		transition.emit("IdlePlayerState")
