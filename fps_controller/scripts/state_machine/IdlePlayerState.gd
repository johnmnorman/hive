class_name IdlePlayerState

extends PlayerMovementState

#@export var ANIMATION : AnimationPlayer
@export var SPEED: float = 5.0
@export var ACCELERATION : float = 0.1
@export var DECELERATION : float = 0.5
#@export var TOP_ANIM_SPEED : float = 4.0
#@onready var STAMINA_COMPONENT : StaminaComponent = %StaminaComponent
#var _anim_speed : float = 1.0
#var MIN_HEIGHT_VARIATION : float = .015
#var MAX_HEIGHT_VARIATION : float = .03
#var _height_variation : float = MIN_HEIGHT_VARIATION

func enter(previous_state) -> void:

	if ANIMATION.current_animation == "jump_end" and ANIMATION.is_playing():
		await ANIMATION.animation_finished
		ANIMATION.play("idle")
	else:
		ANIMATION.play("idle")

func physics_update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	#WEAPON.sway_weapon(delta, true)
	

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
		

		
#func set_animation_speed(spd):
	#var alpha = remap(spd, 0.0, SPEED, 0.0, 1.0)
