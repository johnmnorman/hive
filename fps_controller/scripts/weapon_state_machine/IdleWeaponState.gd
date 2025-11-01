class_name IdleWeaponState
extends WeaponState


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	Global.debug.add_property("AllegedState",PLAYER.current_player_state,3)
	if PLAYER.current_player_state == "SlidingPlayerState":
		pass
	if PLAYER.current_player_state == "FallingPlayerState":
		pass
	if PLAYER.current_player_state == "JumpingPlayerState":
		pass
	if PLAYER.current_player_state == "IdlePlayerState":
		WEAPON.sway_weapon(delta, true)
	if PLAYER.current_player_state == "WalkingPlayerState":
		WEAPON.sway_weapon(delta, false)
		WEAPON.bob_weapon(delta, 5, 1.3)
	if PLAYER.current_player_state == "SprintingPlayerState":
		WEAPON.sway_weapon(delta, false)
		WEAPON.bob_weapon(delta, 8, 2)	
	if PLAYER.current_player_state == "CrouchingPlayerState":
		if PLAYER.velocity.length() > 0.0 and PLAYER.is_on_floor():
			WEAPON.sway_weapon(delta, false)
			WEAPON.bob_weapon(delta, 3, 0.8)
		else:
			WEAPON.sway_weapon(delta, true)

		
func _process(_delta):
	if Input.is_action_just_pressed("attack"):
		WEAPON.attack()
