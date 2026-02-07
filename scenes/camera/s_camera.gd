@tool
extends Node2D
#Camera

@onready var rotater: Node2D = $rotater

@onready var polygon_2d: Polygon2D = $rotater/Area2D/Polygon2D
@onready var collision_polygon_2d: CollisionPolygon2D = $rotater/Area2D/CollisionPolygon2D

var base_color : Color
var angry_color : = Color(0.647, 0.188, 0.188, 0.38)

@export var marker_list : Array[Marker2D]
@export var duration_list: Array[float] = []
#@export var idle_time : float = 5
@export var rotation_speed: float = 5.0 # higher = faster

#area for seraching for player
@onready var area_2d: Area2D = $rotater/Area2D


@onready var timer: Timer = $Timer

var target_rotation: float = 0.0
var current_marker_index : int = 0

var player_ref: Node2D = null
var cops_called := false

var player_is_in_range : bool = false
var in_range_elapsed := 0.0
var total_time_required_till_angry := 0.5

#audio
@onready var sfx_alert: AudioStreamPlayer2D = $"SFX alert"

var is_powered : bool = true

func _ready() -> void:
	Events.connect("call_the_cops", cops_has_been_called)
	
	var polygon : PackedVector2Array = collision_polygon_2d.polygon
	polygon_2d.polygon = polygon
	base_color = polygon_2d.color
	
	#error handling
	if marker_list.is_empty() or duration_list.is_empty():
		push_error("markerlist or duration is empty on a camera")
	
	if marker_list.size() == 1:
		look_at_marker(marker_list[0], 0)
	else:
		start_look_sequence()

func cops_has_been_called() -> void:
	polygon_2d.color = angry_color
	cops_called = true
	
	rotation_speed = 10
	for duration : float in duration_list:
		duration = 0.1
	start_look_sequence()

func _process(delta: float) -> void:
	if player_is_in_range and player_ref and not cops_called:
		var dir: Vector2 = (player_ref.global_position - global_position).normalized()
		target_rotation = dir.angle() - PI / 2
		in_range_elapsed += delta
		var t : float = clamp(in_range_elapsed / total_time_required_till_angry, 0.0, 1.0)

		polygon_2d.color = base_color.lerp(angry_color, t)
		if t >= 1.0:
			cops_called = true
			Events.emit_signal("call_the_cops")
	else:
		in_range_elapsed = max(in_range_elapsed - delta * 2.0, 0.0)

		var t : float = clamp(in_range_elapsed / total_time_required_till_angry, 0.0, 1.0)
		
		if not cops_called:
			polygon_2d.color = base_color.lerp(angry_color, t)

	rotater.rotation = lerp_angle(
		rotater.rotation,
		target_rotation,
		delta * rotation_speed
	)

func on_generator_power_changed(is_on: bool) -> void:
	if is_on:
		is_powered = true
		area_2d.monitoring = true
		polygon_2d.visible = true
		set_process(true)
	else:
		is_powered = false
		area_2d.monitoring = false
		polygon_2d.visible = false
		set_process(false)
		

func look_at_marker(marker : Marker2D, duration : float) -> void:
	var dir: Vector2 = (marker.global_position - global_position).normalized()
	target_rotation = dir.angle() - PI / 2
	
	if duration > 0:
		timer.wait_time = duration
		timer.start()
	else:
		timer.stop()

func start_look_sequence() -> void:
	if marker_list.is_empty():
		return
	
	current_marker_index = 0
	look_at_marker(marker_list[current_marker_index], duration_list[current_marker_index])

func _on_timer_timeout() -> void:
	current_marker_index += 1

	if current_marker_index >= marker_list.size():
		current_marker_index = 0

	var next_marker: Marker2D = marker_list[current_marker_index]
	var next_duration: float = duration_list[current_marker_index]
	look_at_marker(next_marker, next_duration)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_ref = body
		player_is_in_range = true
		cops_called = false
		in_range_elapsed = 0.0

		timer.stop() # stop marker cycling while tracking

		sfx_alert.play()
		polygon_2d.color = angry_color

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		if not cops_called:
			player_is_in_range = false
			player_ref = null
			in_range_elapsed = 0.0

			polygon_2d.color = base_color

			start_look_sequence() # resume patrol
