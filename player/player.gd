extends CharacterBody2D
class_name Player

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var max_speed: float = 80.0
#var current_speed : float
@export var acceleration: float = 400.0
@export var deceleration: float = 1000.0

#roll
@export var roll_speed_multiplier: float = 2
@export var roll_duration: float = 0.1
@export var roll_cooldown: float = 5

var can_move : bool = true
var is_rolling: bool = false

var input_dir: Vector2
var move_dir: Vector2
var last_move_dir: Vector2 = Vector2.DOWN

func _process(_delta: float) -> void:
	pass
	#if is_rolling:
		#print("rolling")

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("roll"):
		_try_roll()

	if can_move and not is_rolling:
		_movement(delta)

	move_and_slide()
	#current_speed = velocity.length()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("use"):
		Events.emit_signal("player_interact_request")

func _movement(delta: float) -> void:
	input_dir = Input.get_vector("left", "right", "up", "down")

	if input_dir != Vector2.ZERO:
		last_move_dir = input_dir.normalized()
		_update_animation(input_dir)
		velocity = velocity.move_toward(
			input_dir * max_speed,
			acceleration * delta
		)
	else:
		_update_animation(Vector2.ZERO)
		velocity = velocity.move_toward(
			Vector2.ZERO,
			deceleration * delta
		)


func _try_roll() -> void:
	if is_rolling:
		return

	is_rolling = true
	can_move = false

	var roll_dir := last_move_dir
	if roll_dir == Vector2.ZERO:
		roll_dir = Vector2.DOWN

	velocity = roll_dir * max_speed * roll_speed_multiplier

	# roll anim
	# animated_sprite_2d.play("roll")

	await get_tree().create_timer(roll_duration).timeout
	is_rolling = false
	can_move = true
	await get_tree().create_timer(roll_cooldown).timeout


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
