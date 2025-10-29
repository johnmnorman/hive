class_name SlidingPlayerState extends PlayerMovementState

@export var SPEED : float = 6.0
@export var ACCELERATION : float = 0.1
@export var DECELERATION : float = 0.25
@export var TILT_AMOUNT : float = 0.09

@export_range(1, 6, 0.1) var SLIDE_ANIM_SPEED : float = 4.0

@onready var CROUCH_SHAPECAST : ShapeCast3D = %ShapeCast3D
var initial_direction : Vector2

func enter(previous_state) -> void:
	#print(PLAYER._current_rotation)
	#set_tilt(PLAYER._current_rotation)
	ANIMATION.get_animation("slide").track_set_key_value(5, 0, PLAYER.velocity.length()) #speed

	initial_direction = Vector2(PLAYER.velocity.x, PLAYER.velocity.z).normalized()
	ANIMATION.speed_scale = 1.0
	ANIMATION.play("slide", -1.0, SLIDE_ANIM_SPEED)
	
func physics_update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_velocity()
	
	# This is the slide's deflection from the starting velocity
	var slide_direction = Vector2(PLAYER.velocity.x, PLAYER.velocity.z).normalized()
	var deflection_in_degrees : float = abs(rad_to_deg(slide_direction.angle_to(initial_direction)))
	
	if Input.is_action_just_pressed("crouch") and PLAYER.is_on_floor():
		transition.emit("CrouchingPlayerState")
	# abort the slide if we hit something at too steep an angle
	if PLAYER.velocity.length() < 1.0 or deflection_in_degrees > 20: 
		transition.emit("CrouchingPlayerState")
	
#func set_tilt(player_rotation) -> void:
	#var tilt = Vector3.ZERO
	#tilt.z = clamp(TILT_AMOUNT * player_rotation, -0.1, 0.1)
	#if tilt.z == 0.0:
		#tilt.z = 0.05
	#
	#ANIMATION.get_animation("slide").track_set_key_value(7, 1, tilt) #CameraController:rotation
	#ANIMATION.get_animation("slide").track_set_key_value(7, 2, tilt)
	
	
func finish():
	transition.emit("CrouchingPlayerState")
