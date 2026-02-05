extends Node2D
#main

@onready var level_container: Node2D = $levelContainer

const FIRST_LEVEL_PATH: String = "res://levels/level_1.tscn"

var next_level_path: String
var current_level_path: String

func _ready() -> void:
	get_window().focus_entered.connect(_on_window_focus_entered)
	get_window().focus_exited.connect(_on_window_focus_exited)

	Events.connect("load_new_level", start_new_level)
	Events.connect("restart_current_level" , restart_level)

	next_level_path = FIRST_LEVEL_PATH
	_setup_new_level()

func _setup_new_level() -> void:
	for child in level_container.get_children():
		child.queue_free()

	var level_scene: PackedScene = load(next_level_path) as PackedScene
	if not level_scene:
		push_error("Failed to load level: " + next_level_path)
		return

	var new_level_scene : PackedScene = load(next_level_path)
	var new_level_instance : Node2D = new_level_scene.instantiate()
	level_container.add_child(new_level_instance)

func restart_level() -> void:
	start_new_level(current_level_path)

func start_new_level(path: String) -> void:
	next_level_path = path
	#animation_player.play("fade_to_black")
	remove_active_cam()







func remove_active_cam() -> void:
	var list := PhantomCameraManager.get_phantom_camera_2ds()
	if list:
		for cam in list:
			cam.priority = 0

func _on_window_focus_entered() -> void:
	pass
	#focus_menu.visible = false

func _on_window_focus_exited() -> void:
	pass
	#focus_menu.visible = true
