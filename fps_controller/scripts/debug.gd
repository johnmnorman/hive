extends PanelContainer

#To use: invoke with
#Globals.debug.add_property("NameString",value_var,order)
#Updates each time it's called

@onready var property_container = %VBoxContainer

#var property
var frames_per_second : String

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
#	add_debug_property("FPS", frames_per_second)
	Global.debug = self

func _input(event):
	if event.is_action_pressed("debug"):
		visible = !visible
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	frames_per_second = "%.2f" % (1.0/delta)
	Global.debug.add_property("FPS",frames_per_second,2)
#	property.text = property.name + ": " + frames_per_second

func add_property(title: String, value, order):
	var target
	target = property_container.find_child(title,true,false)
	if !target:
		target = Label.new()
		property_container.add_child(target)
		target.name = title
		target.text = target.name + ": " + str(value)
	elif visible:
		target.text = title + ": " + str(value)
		property_container.move_child(target, order)
		
#func add_debug_property(title : String, value):
	#property = Label.new()
	#property_container.add_child(property)
	#property.name = title
	#property.text = property.name + ': ' + value
	
