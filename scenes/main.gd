extends Node2D
#main

@onready var level_container: Node2D = $levelContainer
@onready var intro_sequence_sfx: AudioStreamPlayer = $MusicManager/introSequenceSFX

@onready var animation_player: AnimationPlayer = $fadeInOut/AnimationPlayer

#const FIRST_LEVEL_PATH: String = "res://levels/level_1.tscn"

var level_index = 0 # start with 0

var level_list : Array[String] = [
"res://levels/level_1.tscn", 
"res://levels/level_2.tscn",
#"res://levels/level_3.tscn",
#"res://levels/level_4.tscn",
]
const DEBUG_SKIP_INTRO : bool = false

var next_level_path: String
var current_level_path: String

func _ready() -> void:
	get_window().focus_entered.connect(_on_window_focus_entered)
	get_window().focus_exited.connect(_on_window_focus_exited)

	Events.connect("load_new_level", start_new_level)
	Events.connect("restart_current_level" , restart_level)

	next_level_path = level_list[level_index]
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
	
	#audio and wait
	if not DEBUG_SKIP_INTRO:
		intro_sequence_sfx.play()
		await get_tree().create_timer(4.5).timeout
	
	animation_player.play("fade_out")

func restart_level() -> void:
	start_new_level(true)

func start_new_level(to_restart : bool) -> void:
	if not to_restart:
		level_index += 1 
	
	print("main booting level: ", level_index)
	next_level_path = level_list[level_index]
	animation_player.play("fade_to_black")

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


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	#only if fade to black
	if anim_name == "fade_to_black":
		remove_active_cam()
		_setup_new_level()
		
