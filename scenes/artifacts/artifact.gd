extends Node2D
class_name Artifact

signal artifact_collected

@export var sprite_texture : Texture2D
@export var pickup_sfx : AudioStream

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var interactable: Interactable = $Interactable

func _ready() -> void:
	#set the visuals and sfx only if exist in export
	if sprite_texture:
		sprite_2d.texture = sprite_texture
	if pickup_sfx:
		audio_stream_player_2d.stream = pickup_sfx
	
	interactable.player_interacted.connect(_on_collected)

func _on_collected() -> void:
	print("artifact collected")
	artifact_collected.emit()
	#audio_stream_player_2d.play() #TODO uncomment
	
	# wait for sound to finish (optional)
	#await audio_stream_player_2d.finished #TODO uncomment
	
	queue_free()
