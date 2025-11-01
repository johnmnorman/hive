class_name CrouchingIdlePlayerState extends PlayerMovementState

@export var SPEED: float = 3.0
@export var ACCELERATION : float = 0.1
@export var DECELERATION : float = 0.3
@export var TOGGLE_CROUCH : bool = true

@export_range(1, 6, 0.1) var CROUCH_SPEED : float = 4.0

@onready var CROUCH_SHAPECAST : ShapeCast3D = %ShapeCast3D

var RELEASED : bool = false
var CROUCHING_IDLE: bool = false

func enter(previous_state) -> void:

	ANIMATION.speed_scale = 1.0

	CROUCHING_IDLE = true

	
func exit() -> void:
	RELEASED = false

	#CROUCHING_IDLE = false

	
func physics_update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	WEAPON.sway_weapon(delta, false)

func update(_delta):
	if PLAYER.velocity.length() > 00:

		transition.emit("CrouchingPlayerState")
	#WEAPON.bob_weapon(delta, SPEED, 1.0)
	if TOGGLE_CROUCH == false:
		if Input.is_action_just_released("crouch"):
			uncrouch()
		elif Input.is_action_pressed("crouch") == false and RELEASED == false:
			RELEASED = true
			uncrouch()
	else:
		if Input.is_action_just_pressed("crouch"):
			CROUCHING_IDLE = !CROUCHING_IDLE

		if Input.is_action_just_pressed("sprint"):
			CROUCHING_IDLE = false
		
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
		if CROUCH_SHAPECAST.is_colliding() == false and not CROUCHING_IDLE:
			ANIMATION.play("crouch", -1.0, -CROUCH_SPEED * 1.5, true)
			if ANIMATION.is_playing():
				await ANIMATION.animation_finished
			transition.emit("IdlePlayerState")
		elif CROUCH_SHAPECAST.is_colliding() == true:
			await get_tree().create_timer(0.1).timeout
			uncrouch()
