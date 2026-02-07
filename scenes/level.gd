extends Node2D

@export var camera : PhantomCamera2D
@onready var artifact_container: Node2D = $Ysort/ArtifactContainer

var required_amount : int = 0
var collected_amount : int = 0

func _ready() -> void:
	if not camera:
		push_error("cam not defined")
	else:
		camera.priority = 1

	for artifact : Artifact in artifact_container.get_children():
		artifact.artifact_collected.connect(_on_artifact_collected)
		required_amount += 1

	Events.connect("player_trying_to_escape", check_if_level_complete)
	
func _on_artifact_collected() -> void:
	collected_amount += 1
	
	print("Collected: ", collected_amount)
	
	if collected_amount >= required_amount:
		print("player can escape")

func check_if_level_complete() -> void:
	if collected_amount >= required_amount:
		print("player escaped")
		Events.emit_signal("load_new_level", false)
