class_name StaminaComponent extends Node

var PLAYER : Player
@export var BREATHING_ANIMATION : AnimationPlayer
@export var TOP_ANIM_SPEED : float = 4.0
@export_range(0.1,2,0.1) var SPRINT_COST : float = 0.3
@export_range(0.01,2,0.01) var WALK_COST : float = 0.05
@export_range(0.1,1,0.1) var REST_AMOUNT : float = 0.1

var _anim_speed : float = 1.0
var MIN_HEIGHT_VARIATION : float = .015
var MAX_HEIGHT_VARIATION : float = .03
var _height_variation : float = MIN_HEIGHT_VARIATION

var exertion : float
var exertion_max : float = 100.0
# Called when the node enters the scene tree for the first time.
func _ready():
	exertion = 0.0
	await owner.ready
	PLAYER = owner as Player


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if PLAYER.is_breathing and BREATHING_ANIMATION.is_playing() == false:
		BREATHING_ANIMATION.play("breathing")
	if PLAYER.is_breathing == false:
		BREATHING_ANIMATION.pause()
		return
	#Global.debug.add_property("Exertion", exertion, 4)

	if PLAYER.velocity.length() > 6.0 and exertion < exertion_max:
		exertion += SPRINT_COST
	elif PLAYER.velocity.length() > 1.0 and exertion < exertion_max:
		exertion += WALK_COST
	elif exertion > 0.0 and PLAYER.velocity.length() <= 1.0:
		exertion -= REST_AMOUNT

			
	if exertion > exertion_max:
		exertion = exertion_max

	if exertion < 0.0:
		exertion = 0.0
		
	#modulate idle animation by exertion level for breathing effect
	_anim_speed = remap(exertion, 0.0, exertion_max, 1.0, TOP_ANIM_SPEED)
	BREATHING_ANIMATION.speed_scale = _anim_speed
	
	_height_variation = remap(exertion, 0.0, exertion_max, MIN_HEIGHT_VARIATION, MAX_HEIGHT_VARIATION)
	BREATHING_ANIMATION.get_animation("breathing").track_set_key_value(0, 1, _height_variation)
	BREATHING_ANIMATION.get_animation("breathing").track_set_key_value(0, 3, -_height_variation)
