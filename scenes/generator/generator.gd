extends Interactable
class_name Generator

@export var electronic_object_list : Array[Node]
@export var turn_back_on_time : float

#ui
@onready var radial_indicator: TextureRect = $radialIndicator
@onready var turn_back_on_timer: Timer = $Timer

@onready var interactable: Interactable = $Interactable
@onready var screen_on: Sprite2D = $base/screenON


#sfx
@onready var sfx_hum: AudioStreamPlayer2D = $sfxHum
@onready var sfx_on: AudioStreamPlayer2D = $sfxOn
@onready var sfx_off: AudioStreamPlayer2D = $sfxOff
@onready var sfx_countdown: AudioStreamPlayer2D = $sfxCountdown

#controlling stuff
var is_turned_on : bool = true

#for shaking
var original_position : Vector2
var shake_strength : float = 0.15

signal power_state_changed(is_on: bool)

func _ready() -> void:
	sfx_hum.play()
	original_position = position # used for shaking and resetting position back
	interactable.connect("player_interacted", update_electronic_objects)
	
	#subscribe the camera and laser
	if !electronic_object_list.is_empty():
		for object in electronic_object_list:
			if object.has_method("on_generator_power_changed"):
				power_state_changed.connect(object.on_generator_power_changed)
		#power_state_changed.emit(is_turned_on) #since object is not loaded yet. can't do this
	
	#timer
	turn_back_on_timer.wait_time = turn_back_on_time
	
	screen_on.visible = true
	radial_indicator.visible = false
		

func _process(_delta: float) -> void:
	if is_turned_on:
		position = original_position + Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
	else:
		position = original_position
	
	_update_radial_indicator()

func update_electronic_objects() -> void:
	is_turned_on = !is_turned_on

	print("generator is now: ", is_turned_on)
	if is_turned_on:
		turn_generator_on()
	else:
		turn_generator_off()
	
	power_state_changed.emit(is_turned_on)
	

func _update_radial_indicator() -> void:
	if turn_back_on_timer.is_stopped():
		return
	
	var time_ratio = turn_back_on_timer.time_left / turn_back_on_timer.wait_time
	
	radial_indicator.material.set_shader_parameter("removed_segments", time_ratio)

func turn_generator_on() -> void:
	screen_on.visible = true
	radial_indicator.visible = false
	
	sfx_hum.play()
	sfx_on.play()
	sfx_countdown.stop()
	
	#update_electronic_objects()
	

func turn_generator_off()  -> void:
	screen_on.visible = false
	radial_indicator.visible = true
	turn_back_on_timer.start()
	
	sfx_hum.play()
	sfx_off.play()
	sfx_countdown.play()


func _on_timer_timeout() -> void:
	update_electronic_objects()
