class_name CrouchingPlayerState extends PlayerMovementState

@export var SPEED: float = 3.0
@export var ACCELERATION : float = 0.1
@export var DECELERATION : float = 0.3
@export var TOGGLE_CROUCH : bool = true
@export var TOP_ANIM_SPEED : float = 1.5
@export_range(1, 6, 0.1) var CROUCH_SPEED : float = 4.0

@onready var CROUCH_SHAPECAST : ShapeCast3D = %ShapeCast3D

var RELEASED : bool = false
var CROUCHING: bool = false

# TODO Idle state has an await that can override the crouch animation.
# Maybe make the crouch a tween function instead of animation player,
# so that crouching can't be overridden by other animations?

func enter(previous_state) -> void:
	Global.debug._print("Entering crouched state.")

	CROUCH_HANDLER.speed_scale = 1.0
	if previous_state.name != "SlidingPlayerState":
		CROUCH_HANDLER.play("crouching/crouch", -1.0, CROUCH_SPEED)

	elif previous_state.name == "SlidingPlayerState":
		CROUCH_HANDLER.current_animation = "crouching/crouch"
		CROUCH_HANDLER.seek(1.0, true)
	CROUCHING = true

	if ANIMATION.is_playing() and ANIMATION.current_animation == "jump_end":
		await ANIMATION.animation_finished
		ANIMATION.play("walk",-1.0,1.0)
	else:
		ANIMATION.play("walk",-1.0,1.0)

	
func exit() -> void:
	RELEASED = false
	
	#CROUCHING = false

	
func physics_update(delta):

	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	set_animation_speed(PLAYER.velocity.length())

func update(_delta):
	if TOGGLE_CROUCH == false:
		if Input.is_action_just_released("crouch"):
			uncrouch()
		elif Input.is_action_pressed("crouch") == false and RELEASED == false:
			RELEASED = true
			uncrouch()
	elif TOGGLE_CROUCH:
		if Input.is_action_just_pressed("crouch"):

			CROUCHING = !CROUCHING
		if Input.is_action_just_pressed("sprint"):
			CROUCHING = false

		toggle_crouch()
		
	if PLAYER.velocity.y < 0.0 and !PLAYER.is_on_floor():
		transition.emit("FallingPlayerState")

	
		
func uncrouch():
	if CROUCH_SHAPECAST.is_colliding() == false and Input.is_action_pressed("crouch") == false:
		CROUCH_HANDLER.play("crouching/crouch", -1.0, -CROUCH_SPEED * 1.5, true)
		if CROUCH_HANDLER.is_playing():
			await CROUCH_HANDLER.animation_finished
		transition.emit("IdlePlayerState")
	elif CROUCH_SHAPECAST.is_colliding() == true:
		await get_tree().create_timer(0.1).timeout
		uncrouch()

func toggle_crouch():
	if CROUCH_SHAPECAST.is_colliding() == false and not CROUCHING:
		CROUCH_HANDLER.play("crouching/crouch", -1.0, -CROUCH_SPEED * 1.5, true)
		if CROUCH_HANDLER.is_playing():
			await CROUCH_HANDLER.animation_finished
		transition.emit("IdlePlayerState")
	elif CROUCH_SHAPECAST.is_colliding() == true and not CROUCHING:
		await get_tree().create_timer(0.1).timeout
		toggle_crouch()

func set_animation_speed(spd):
	var alpha = remap(spd, 0.0, SPEED, 0.0, 1.0)
	ANIMATION.speed_scale = lerp(0.0, TOP_ANIM_SPEED, alpha)
