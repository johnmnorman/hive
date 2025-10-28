class_name JumpingPlayerState extends PlayerMovementState

@export var SPEED: float = 8.5
@export var ACCELERATION : float = 0.02
@export var DECELERATION : float = 0.005
@export var JUMP_VELOCITY : float = 7

@export_range(0.1, 1.0, 0.01) var INPUT_MULTIPLIER : float = 0.85

@export var ENABLE_DOUBLE_JUMP : bool = true
@export_range(0.4, 1.5, 0.1) var DOUBLE_JUMP_MULTIPLIER : float = 0.8

var jumped_twice: bool = false
func enter(previous_state) -> void:
	PLAYER.velocity.y += JUMP_VELOCITY
	ANIMATION.play("jump_start")

func exit() -> void:
	jumped_twice = false
	
func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED * INPUT_MULTIPLIER, ACCELERATION, DECELERATION)
	
	if jumped_twice == false and Input.is_action_just_pressed("jump"):
		PLAYER.velocity.y = JUMP_VELOCITY * DOUBLE_JUMP_MULTIPLIER
		ANIMATION.play("jump_midair")
		jumped_twice = true
		
	
	if Input.is_action_just_released("jump"):
		if PLAYER.velocity.y > 0:
			PLAYER.velocity.y = PLAYER.velocity.y / 2.0

	PLAYER.update_velocity()
	
	if PLAYER.is_on_floor():
		ANIMATION.play("jump_end")
		transition.emit("IdlePlayerState")
