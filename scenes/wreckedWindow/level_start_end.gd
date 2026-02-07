extends Node2D
#level start end



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("player trying to escape")
		Events.emit_signal("player_trying_to_escape")
	pass # Replace with function body.
