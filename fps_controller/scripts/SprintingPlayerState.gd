class_name SprintingPlayerState extends PlayerMovementState
#@export var ANIMATION : AnimationPlayer
@export var SPEED: float = 8.5
@export var ACCELERATION : float = 0.15
@export var DECELERATION : float = 0.4

@export var TOP_ANIM_SPEED : float = 2

func enter(previous_state) -> void:
	if ANIMATION.is_playing() and ANIMATION.current_animation == "jump_end":
		await ANIMATION.animation_finished
		ANIMATION.play("sprint", 0.5, 1.0)
	else:	
		ANIMATION.play("sprint", 0.5, 1.0)
	
func exit() -> void:
	ANIMATION.speed_scale = 1.0
	
func update(delta):
	set_animation_speed(Global.player.velocity.length())
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	if Input.is_action_just_released("sprint") or PLAYER.velocity.length() == 0: 
			transition.emit("IdlePlayerState")

	if Input.is_action_just_pressed("crouch") and PLAYER.velocity.length() > 6:
		transition.emit("SlidingPlayerState")
		
	if Input.is_action_just_pressed("jump") and PLAYER.is_on_floor():
		transition.emit("JumpingPlayerState")
		
func set_animation_speed(spd):
	var alpha = remap(spd, 0.0, SPEED, 0.0, 1.0)
	ANIMATION.speed_scale = lerp(0.0, TOP_ANIM_SPEED, alpha)
