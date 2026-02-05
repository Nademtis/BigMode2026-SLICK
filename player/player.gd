extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var max_speed: float = 80.0
var current_speed : float
@export var acceleration: float = 400.0
@export var deceleration: float = 1000.0

var can_move : bool = true
var input_dir: Vector2
var move_dir: Vector2


func _physics_process(delta: float) -> void:
	if can_move:
		_movement(delta)
	#_handle_footsteps(delta)
	
	
	
func _movement(delta: float) -> void:
	input_dir = Input.get_vector("left", "right", "up", "down")
	_update_animation(input_dir)

	if input_dir != Vector2.ZERO:
		velocity = velocity.move_toward(input_dir * max_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
	move_and_slide()


func _update_animation(dir: Vector2) -> void:

	if dir == Vector2.ZERO:
		animated_sprite_2d.play("idle")
		return

	if abs(dir.x) > abs(dir.y):
		animated_sprite_2d.play("E_walk")
		animated_sprite_2d.flip_h = dir.x < 0
	else:
		animated_sprite_2d.flip_h = false
		if dir.y < 0:
			animated_sprite_2d.play("N_walk")
		else:
			animated_sprite_2d.play("S_walk")
