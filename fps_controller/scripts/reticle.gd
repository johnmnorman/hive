extends CenterContainer

@export var DOT_RADIUS : float = 1.0
@export var DOT_COLOR : Color = Color.WHITE
@export var RETICLE_LINES : Array[Line2D]
@export var PLAYER_CONTROLLER: CharacterBody3D	
@export var RETICLE_SPEED : float = 0.25
@export var RETICLE_DISTANCE : float = 2.0
@onready var STAMINA_COMPONENT : StaminaComponent = %StaminaComponent

var opacity : float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	queue_redraw()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	adjust_reticle_lines()
	queue_redraw()
	
func _draw():
	DOT_COLOR.a = opacity
	draw_circle(Vector2(0,0),DOT_RADIUS,DOT_COLOR)

func adjust_reticle_lines():
	var vel = PLAYER_CONTROLLER.get_real_velocity()
	opacity = remap(STAMINA_COMPONENT.exertion, 0.0, STAMINA_COMPONENT.exertion_max, 1.0, 0.05)
	var origin = Vector3(0,0,0)
	var pos = Vector2(0,0)
	var speed = origin.distance_to(vel)
	
	RETICLE_LINES[0].position = lerp(RETICLE_LINES[0].position, pos + Vector2(0, -speed * RETICLE_DISTANCE), RETICLE_SPEED) #top
	#RETICLE_LINES[0].default_color.a = opacity
	
	RETICLE_LINES[1].position = lerp(RETICLE_LINES[1].position, pos + Vector2(speed * RETICLE_DISTANCE, 0), RETICLE_SPEED) #right
	#RETICLE_LINES[1].default_color.a = opacity
	
	RETICLE_LINES[2].position = lerp(RETICLE_LINES[2].position, pos + Vector2(0, speed * RETICLE_DISTANCE), RETICLE_SPEED) #bottom
	#RETICLE_LINES[2].default_color.a = opacity
	
	RETICLE_LINES[3].position = lerp(RETICLE_LINES[3].position, pos + Vector2(-speed * RETICLE_DISTANCE, 0), RETICLE_SPEED) #left
	#RETICLE_LINES[3].default_color.a = opacity
