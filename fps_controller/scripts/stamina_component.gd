class_name StaminaComponent extends Node

var PLAYER : Player
var ANIMATION : AnimationPlayer
@export_range(0.1,2,0.1) var SPRINT_COST : float = 0.3
@export_range(0.01,2,0.01) var WALK_COST : float = 0.05
@export_range(0.1,1,0.1) var REST_AMOUNT : float = 0.2
var exertion : float
var exertion_max : float = 100.0
# Called when the node enters the scene tree for the first time.
func _ready():
	exertion = 0.0
	await owner.ready
	PLAYER = owner as Player
	ANIMATION = PLAYER.ANIMATION_PLAYER


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
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
