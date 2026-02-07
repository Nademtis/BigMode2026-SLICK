extends Node2D
class_name Interactable

signal player_interacted()

var player_in_range : bool = false

#for anim
var hover_scale_amount : float = 0.05
var hover_duration : float = 0.08
var original_scale : Vector2
var tween : Tween

func _ready() -> void:
	Events.connect("player_interact_request", interact_check)
	original_scale = get_parent().scale

func interact_check() -> void:
	#player has requested interact, check if is in range then emit
	print("interact request")
	if player_in_range:
		confirmed_interact()
		
func confirmed_interact():
	#objects inheriting from this script should subscribe to this signal 
	emit_signal("player_interacted")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("player entered")
		player_in_range = true
		_play_hover_feedback()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false


func _play_hover_feedback() -> void:
	if tween:
		tween.kill()

	var parent_node = get_parent()
	tween = create_tween()

	var target_scale = original_scale + Vector2.ONE * hover_scale_amount
	tween.tween_property(parent_node, "scale", target_scale, hover_duration)
	tween.tween_property(parent_node, "scale", original_scale, hover_duration)
