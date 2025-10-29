class_name CrouchingPlayerState extends PlayerMovementState

@export var SPEED: float = 3.0
@export var ACCELERATION : float = 0.1
@export var DECELERATION : float = 0.3
@export var TOGGLE_CROUCH : bool = true

@export_range(1, 6, 0.1) var CROUCH_SPEED : float = 4.0

@onready var CROUCH_SHAPECAST : ShapeCast3D = %ShapeCast3D

var RELEASED : bool = false
var CROUCHING: bool = false

func enter(previous_state) -> void:
	ANIMATION.speed_scale = 1.0
	if previous_state.name != "SlidingPlayerState":
		ANIMATION.play("crouch", -1.0, CROUCH_SPEED)
	elif previous_state.name == "SlidingPlayerState":
		ANIMATION.current_animation = "crouch"
		ANIMATION.seek(1.0, true)
	CROUCHING = true

	
func exit() -> void:
	RELEASED = false
	CROUCHING = false

	
func physics_update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	if TOGGLE_CROUCH == false:
		if Input.is_action_just_released("crouch"):
			uncrouch()
		elif Input.is_action_pressed("crouch") == false and RELEASED == false:
			RELEASED = true
			uncrouch()
	else:
		if Input.is_action_just_pressed("crouch"):
			CROUCHING = !CROUCHING
		if Input.is_action_just_pressed("sprint"):
			CROUCHING = false
		uncrouch()
		
	if PLAYER.velocity.y < 0.0 and !PLAYER.is_on_floor():
		transition.emit("FallingPlayerState")
	
		
func uncrouch():
	if TOGGLE_CROUCH == false:
		if CROUCH_SHAPECAST.is_colliding() == false and Input.is_action_pressed("crouch") == false:
			ANIMATION.play("crouch", -1.0, -CROUCH_SPEED * 1.5, true)
			if ANIMATION.is_playing():
				await ANIMATION.animation_finished
			transition.emit("IdlePlayerState")
		elif CROUCH_SHAPECAST.is_colliding() == true:
			await get_tree().create_timer(0.1).timeout
			uncrouch()
	elif TOGGLE_CROUCH == true:
		if CROUCH_SHAPECAST.is_colliding() == false and not CROUCHING:
			ANIMATION.play("crouch", -1.0, -CROUCH_SPEED * 1.5, true)
			if ANIMATION.is_playing():
				await ANIMATION.animation_finished
			transition.emit("IdlePlayerState")
		elif CROUCH_SHAPECAST.is_colliding() == true:
			await get_tree().create_timer(0.1).timeout
			uncrouch()
