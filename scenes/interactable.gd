extends Node2D
class_name Interactable

signal player_interacted()

var player_in_range : bool = false

func _ready() -> void:
	Events.connect("player_interact_request", interact_check)



func interact_check() -> void:
	#player has requested interact, check if is in range then emit
	print("interact request")
	if player_in_range:
		confirmed_interact()
		
func confirmed_interact():
	#confirm this interaction
	#objects inheriting from this script should subscribe to this signal 
	emit_signal("player_interacted")


func _on_area_2d_body_entered(body: Node2D) -> void:
	print("something entered")
	if body.is_in_group("player"):
		print("player entered")
		player_in_range = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	print("something exited")
	
	if body.is_in_group("player"):
		player_in_range = false
	
