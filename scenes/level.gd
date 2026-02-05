extends Node2D

@export var camera : PhantomCamera2D

func _ready() -> void:
	if not camera:
		push_error("cam not defined")
	else:
		camera.priority = 1
