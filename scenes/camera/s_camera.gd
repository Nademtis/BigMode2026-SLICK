@tool
extends Node2D
#Camera

@onready var rotater: Node2D = $rotater

@onready var polygon_2d: Polygon2D = $rotater/Area2D/Polygon2D
@onready var collision_polygon_2d: CollisionPolygon2D = $rotater/Area2D/CollisionPolygon2D

@export var marker_list : Array[Marker2D]
@export var duration_list: Array[float] = []
#@export var idle_time : float = 5
@export var rotation_speed: float = 5.0 # higher = faster

#area for seraching for player
@onready var area_2d: Area2D = $rotater/Area2D


@onready var timer: Timer = $Timer

var target_rotation: float = 0.0
var current_marker_index : int = 0


var is_powered : bool = true

func _ready() -> void:
	var polygon : PackedVector2Array = collision_polygon_2d.polygon
	polygon_2d.polygon = polygon
	
	#error handling
	if marker_list.is_empty() or duration_list.is_empty():
		push_error("markerlist or duration is empty on a camera")
	
	if marker_list.size() == 1:
		look_at_marker(marker_list[0], 0)
	else:
		start_look_sequence()


func _process(delta: float) -> void:
	rotater.rotation = lerp_angle(rotater.rotation, target_rotation, delta * rotation_speed)


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

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var player : Player = body
		print("!!!camera found player!!!")


func _on_timer_timeout() -> void:
	current_marker_index += 1

	if current_marker_index >= marker_list.size():
		current_marker_index = 0

	var next_marker: Marker2D = marker_list[current_marker_index]
	var next_duration: float = duration_list[current_marker_index]
	look_at_marker(next_marker, next_duration)
