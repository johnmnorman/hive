class_name Player 
extends CharacterBody3D

#based on the generous work of StayAtHome Dev

const SPEED = 5.0


var _mouse_input : bool = false
var _rotation_input : float
var _tilt_input : float
var _mouse_rotation : Vector3
var _player_rotation : Vector3
var _camera_rotation : Vector3
var _current_rotation : float

var _speed : float

@export var SPEED_DEFAULT : float = 5.0
@export var SPEED_SPRINTING : float = 8.5

@export var ACCELERATION : float = 0.1
@export var DECELERATION : float = 0.25
@export var MOUSE_SENSITIVITY : float = 0.5
@export var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(90.0)
@export var CAMERA_CONTROLLER : Node3D
@export var ANIMATION_PLAYER : AnimationPlayer
@export var WEAPON_CONTROLLER : WeaponController

@export_range(5, 10, 0.1) var CROUCH_SPEED : float = 7.0

var DEBUG_initialdir : Vector2
func _input(event):
	if event.is_action_pressed("exit"):
		get_tree().quit()
		
func _unhandled_input(event):
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x * MOUSE_SENSITIVITY
		_tilt_input = -event.relative.y * MOUSE_SENSITIVITY
		
func _update_camera(delta):
	_current_rotation = _rotation_input
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	_mouse_rotation.y += _rotation_input * delta
	
	_player_rotation = Vector3(0.0,_mouse_rotation.y,0.0)
	_camera_rotation = Vector3(_mouse_rotation.x,0.0,0.0)
	
	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(_camera_rotation)
	CAMERA_CONTROLLER.rotation.z = 0.0
	
	global_transform.basis = Basis.from_euler(_player_rotation)
	
	_rotation_input = 0.0
	_tilt_input = 0.0


func _ready():
	Global.player = self

	_speed = SPEED_DEFAULT
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#CROUCH_SHAPECAST.add_exception($".")

func _physics_process(delta):
	#Global.debug.add_property(CUR_speed,3)
	pass

func _process(delta) -> void:
	_update_camera(delta)

func update_gravity(delta) -> void:
	if is_on_floor() == false:
		velocity += get_gravity() * delta

func update_input(speed: float, acceleration: float, deceleration: float) -> void:
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = lerp(velocity.x, direction.x * speed, acceleration)
		velocity.z = lerp(velocity.z, direction.z * speed, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration)
		velocity.z = move_toward(velocity.z, 0, deceleration)
	
func update_velocity() -> void:
		move_and_slide()
