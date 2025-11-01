class_name IdlePlayerState

extends PlayerMovementState

#@export var ANIMATION : AnimationPlayer
@export var SPEED: float = 5.0
@export var ACCELERATION : float = 0.1
@export var DECELERATION : float = 0.5
@export var TOP_ANIM_SPEED : float = 4.0
@onready var STAMINA_COMPONENT : StaminaComponent = %StaminaComponent
var _anim_speed : float = 1.0
var MIN_HEIGHT_VARIATION : float = .015
var MAX_HEIGHT_VARIATION : float = .03
var _height_variation : float = MIN_HEIGHT_VARIATION

func enter(previous_state) -> void:

	if previous_state.name == "FallingPlayerState" or previous_state.name == "JumpingPlayerState":
		#ANIMATION.play("jump_end")
		#await ANIMATION.animation_finished
		ANIMATION.play("idle")
	else:
		ANIMATION.play("idle")

func physics_update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	#WEAPON.sway_weapon(delta, true)
	
	#modulate idle animation by exertion level for breathing effect
	_anim_speed = remap(STAMINA_COMPONENT.exertion, 0.0, STAMINA_COMPONENT.exertion_max, 1.0, TOP_ANIM_SPEED)
	ANIMATION.speed_scale = _anim_speed
	
	_height_variation = remap(STAMINA_COMPONENT.exertion, 0.0, STAMINA_COMPONENT.exertion_max, MIN_HEIGHT_VARIATION, MAX_HEIGHT_VARIATION)
	ANIMATION.get_animation("idle").track_set_key_value(0, 1, 1.8+_height_variation)
	ANIMATION.get_animation("idle").track_set_key_value(0, 3, 1.8-_height_variation)
	#Global.debug.add_property("Height_variation",_height_variation,4)

func update(_delta) -> void:

	if Input.is_action_just_pressed("crouch") and PLAYER.is_on_floor():
		transition.emit("CrouchingPlayerState")
		
	if Global.player.velocity.length() > 0.0 and Global.player.is_on_floor():
		if Input.is_action_pressed("sprint"):
			transition.emit("SprintingPlayerState")
		else:
			transition.emit("WalkingPlayerState")
	
	if Input.is_action_just_pressed("jump") and PLAYER.is_on_floor():
		transition.emit("JumpingPlayerState")
		
	if PLAYER.velocity.y < 0.0 and !PLAYER.is_on_floor():
		transition.emit("FallingPlayerState")
		

		
func set_animation_speed(spd):
	var alpha = remap(spd, 0.0, SPEED, 0.0, 1.0)
