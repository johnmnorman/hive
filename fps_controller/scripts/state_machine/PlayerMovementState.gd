class_name PlayerMovementState
extends State

var PLAYER: Player
var ANIMATION: AnimationPlayer
var WEAPON: WeaponController
var CROUCH_HANDLER : AnimationPlayer

func _ready() -> void:
	await owner.ready
	PLAYER = owner as Player
	ANIMATION = PLAYER.ANIMATION_PLAYER
	CROUCH_HANDLER = PLAYER.CROUCH_HANDLER
	WEAPON = PLAYER.WEAPON_CONTROLLER
	
func _process(delta: float) -> void:
	pass
