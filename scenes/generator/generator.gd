extends Interactable
class_name Generator

@onready var radial_indicator: TextureRect = $radialIndicator

var is_turned_on : bool = true
@onready var interactable: Interactable = $Interactable
@onready var screen_on: Sprite2D = $base/screenON

@export var electronic_object_list : Array[Node]

#for shaking
var original_position : Vector2
@export var shake_strength : float = 0.15

signal power_state_changed(is_on: bool)

func _ready() -> void:
	original_position = position # used for shaking and resetting position back
	interactable.connect("player_interacted", update_electronic_objects)
	
	#subscribe the camera and laser
	if !electronic_object_list.is_empty():
		for object in electronic_object_list:
			if object.has_method("on_generator_power_changed"):
				power_state_changed.connect(object.on_generator_power_changed)
		#power_state_changed.emit(is_turned_on)
	
	if is_turned_on:
		turn_generator_on()
	else:
		turn_generator__off()
		

func _process(_delta: float) -> void:
	if is_turned_on:
		position = original_position + Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
	else:
		position = original_position

func update_electronic_objects() -> void:
	is_turned_on = !is_turned_on

	if is_turned_on:
		turn_generator_on()
	else:
		turn_generator__off()
	
	power_state_changed.emit(is_turned_on)
	

func turn_generator_on() -> void:
	screen_on.visible = true
	radial_indicator.visible = false
	

func turn_generator__off()  -> void:
	screen_on.visible = false
	radial_indicator.visible = true
	
