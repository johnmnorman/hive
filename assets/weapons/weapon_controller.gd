@tool
class_name WeaponController extends Node3D

@export var WEAPON_TYPE : Weapons:
	set(value):
		WEAPON_TYPE = value
		if Engine.is_editor_hint():
			load_weapon()

@export var sway_noise : NoiseTexture2D
@export var sway_speed : float = 1.2
@export var reset : bool = false:
	set(value):
		reset = value
		if Engine.is_editor_hint():
			load_weapon()
			
@export var bob_speed_minimum: float = 3.0
@export var bob_speed_maximum: float = 12.0
@export var bob_horizontal_maximum: float = 15.0
@export var bob_vertical_maximum: float = 12.0
@onready var weapon_mesh : MeshInstance3D = %WeaponMesh
#@onready var weapon_shadow : MeshInstance3D

var mouse_movement : Vector2
var random_sway_x
var random_sway_y
var random_sway_amount : float
var time : float = 0.0
var idle_sway_adjustment
var idle_sway_rotation_strength
var weapon_bob_amount : Vector2 = Vector2(0,0)
var current_bob_speed: float = 0.0

var bullet_hole_decal = preload("res://scenes/bullet_hole.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	await owner.ready
	load_weapon()

func _input(event):
	if event.is_action_pressed("weapon_1"):
		WEAPON_TYPE = load("res://assets/weapons/pipe/pipe.tres")
		load_weapon()
	if event.is_action_pressed("weapon_2"):
		WEAPON_TYPE = load("res://assets/weapons/pipe/pipeL.tres")
		load_weapon()
	if event is InputEventMouseMotion:
		mouse_movement = event.relative

# Called every frame. 'delta' is the elapsed time since the previous frame.
func load_weapon() -> void:
	weapon_mesh.mesh = WEAPON_TYPE.mesh
	position = WEAPON_TYPE.position
	rotation_degrees = WEAPON_TYPE.rotation
	scale = WEAPON_TYPE.scale
#	weapon_shadow.visible = WEAPON_TYPE.shadow
	idle_sway_adjustment = WEAPON_TYPE.idle_sway_adjustment
	idle_sway_rotation_strength = WEAPON_TYPE.idle_sway_rotation_strength
	random_sway_amount = WEAPON_TYPE.random_sway_amount
	
func sway_weapon(delta, is_idle: bool) -> void:
	# Clamp mouse movement
	#Global.debug.add_property("Sway",weapon_bob_amount,5)
	mouse_movement = mouse_movement.clamp(WEAPON_TYPE.sway_min, WEAPON_TYPE.sway_max)
		
	if is_idle:

		var sway_random : float = get_sway_noise()
		var sway_random_adjusted : float = sway_random * idle_sway_adjustment # adjust sway strength
		
		# Create time with delta and set two sine values for x and y sway movement
		time += delta * (sway_speed + sway_random)
		random_sway_x = sin(time * 1.5 + sway_random_adjusted) / random_sway_amount
		random_sway_y = sin(time - sway_random_adjusted) / random_sway_amount
	

		#Lerp weapon pos based on mouse movement
		position.x = lerp(position.x, WEAPON_TYPE.position.x - (mouse_movement.x * WEAPON_TYPE.sway_amount_position + random_sway_x) 
			* delta, WEAPON_TYPE.sway_speed_position)
		position.y = lerp(position.y, WEAPON_TYPE.position.y + (mouse_movement.y * WEAPON_TYPE.sway_amount_position + random_sway_y) 
			* delta, WEAPON_TYPE.sway_speed_position)
		#lerp weapon rot based on mouse
		rotation_degrees.y = lerp(rotation_degrees.y, WEAPON_TYPE.rotation.y + (mouse_movement.x * WEAPON_TYPE.sway_amount_rotation + 
			(random_sway_y * idle_sway_rotation_strength)) * delta, WEAPON_TYPE.sway_speed_rotation)
		rotation_degrees.x = lerp(rotation_degrees.x, WEAPON_TYPE.rotation.x - (mouse_movement.y * WEAPON_TYPE.sway_amount_rotation + 
			(random_sway_x * idle_sway_rotation_strength)) * delta, WEAPON_TYPE.sway_speed_rotation)
	
	else:
		
				#Movement lerp
		position.x = lerp(position.x, WEAPON_TYPE.position.x - (mouse_movement.x * WEAPON_TYPE.sway_amount_position + 
			weapon_bob_amount.x) * delta, WEAPON_TYPE.sway_speed_position)
		position.y = lerp(position.y, WEAPON_TYPE.position.y + (mouse_movement.y * WEAPON_TYPE.sway_amount_position +
			weapon_bob_amount.y) * delta, WEAPON_TYPE.sway_speed_position)
		#lerp weapon rot based on mouse
		rotation_degrees.y = lerp(rotation_degrees.y, WEAPON_TYPE.rotation.y + (mouse_movement.x * WEAPON_TYPE.sway_amount_rotation)
 			* delta, WEAPON_TYPE.sway_speed_rotation)
		rotation_degrees.x = lerp(rotation_degrees.x, WEAPON_TYPE.rotation.x - (mouse_movement.y * WEAPON_TYPE.sway_amount_rotation) 
			* delta, WEAPON_TYPE.sway_speed_rotation)
	
func bob_weapon(delta, player_speed: float, bob_multiplier: float) -> void:
	#bob_speed: 7 is sane for walking
	#hbob and vbob can be ~10 for walking
	current_bob_speed = player_speed + 3
	var hbob_amount = player_speed * bob_multiplier * WEAPON_TYPE.weapon_inertia_factor
	var vbob_amount = player_speed * bob_multiplier * 0.8 * WEAPON_TYPE.weapon_inertia_factor
	time += delta
	
	weapon_bob_amount.x = sin(time*current_bob_speed) * hbob_amount
	weapon_bob_amount.y = -abs(cos(time * current_bob_speed) * vbob_amount)
	
func get_sway_noise() -> float:
	var player_position : Vector3 = Vector3(0,0,0)
	
	if not Engine.is_editor_hint():
		player_position = Global.player.global_position
	
	var noise_location : float = sway_noise.noise.get_noise_2d(player_position.x,player_position.y)
		
	return noise_location

func attack() -> void:
	Global.debug._print("Attack raycast:")
	var camera = Global.player.CAMERA_CONTROLLER
	var space_state = camera.get_world_3d().direct_space_state
	var screen_center = get_viewport().size / 2
	Global.debug._print(screen_center)
	var origin = camera.global_position
	var forward = -camera.global_transform.basis.z
	var end = origin + forward * 1000
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_bodies = true
	query.collide_with_areas = true
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	Global.debug._print(result)
	if result:
		_bullet_hole(result.get("position"), result.get("normal"))
	
func _bullet_hole(position: Vector3, normal: Vector3) -> void:
	var instance = bullet_hole_decal.instantiate()
	get_tree().root.add_child(instance)
	instance.global_position = position
	instance.look_at(instance.global_transform.origin + normal, Vector3.UP)
	instance.rotate_object_local(Vector3(1,0,0), 90)
	await get_tree().create_timer(30).timeout
	var fade = get_tree().create_tween()
	fade.tween_property(instance, "modulate:a", 0.0, 1.5)
	await get_tree().create_timer(1.5).timeout
	instance.queue_free()
	
#func _physics_process(delta):
	#_bob_weapon(delta, 5.0, 0.05, 0.02)
