extends CharacterBody2D
class_name Player

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var max_speed: float = 80.0
#var current_speed : float
@export var acceleration: float = 400.0
@export var deceleration: float = 600.0

#roll
@export var roll_speed_multiplier: float = 2
@export var roll_duration: float = 0.28
@export var roll_cooldown: float = 5
@export var slide_recovery_time: float = 0.15
var is_slide_recovering: bool = false # used to make slide animation longer without changing logic

var can_move : bool = true
var is_rolling: bool = false

var input_dir: Vector2
var move_dir: Vector2
var last_move_dir: Vector2 = Vector2.DOWN

#audio
@onready var sfx_walk_carpet: AudioStreamPlayer2D = $SFXwalkCarpet
var footstep_cooldown := 0.0 # don't change - used for when to play footstep
var footstep_interval := 0.31 # the interval for howw often steps are played

func _ready() -> void:
	animated_sprite_2d.speed_scale = 0.8

func _process(_delta: float) -> void:
	if is_rolling:
		set_collision_mask_value(1, false)
	else:
		set_collision_mask_value(1, true)
		

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("roll"):
		_try_roll()

	if can_move and not is_rolling:
		_movement(delta)
		handle_footsteps(delta)	

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

func handle_footsteps(delta: float) -> void:
	if velocity.length() > 10.0:
		footstep_cooldown -= delta

		if footstep_cooldown <= 0.0:
			_play_footstep()
			footstep_cooldown = footstep_interval
	else:
		footstep_cooldown = 0.0

func _play_footstep() -> void:
	sfx_walk_carpet.play()

func _try_roll() -> void:
	if is_rolling:
		return

	is_rolling = true
	can_move = false

	var roll_dir := last_move_dir
	if roll_dir == Vector2.ZERO:
		roll_dir = Vector2.DOWN

	velocity = roll_dir * max_speed * roll_speed_multiplier

	_play_slide_animation(roll_dir)
	# roll anim
	# animated_sprite_2d.play("roll")

	await get_tree().create_timer(roll_duration).timeout
	
	is_rolling = false
	is_slide_recovering = true
	can_move = true
	await get_tree().create_timer(slide_recovery_time).timeout
	
	is_slide_recovering = false
	
	await get_tree().create_timer(roll_cooldown).timeout

func _play_slide_animation(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		animated_sprite_2d.play("slide_right")
		animated_sprite_2d.flip_h = dir.x < 0
	else:
		animated_sprite_2d.flip_h = false
		if dir.y < 0:
			animated_sprite_2d.play("slide_up")
		else:
			animated_sprite_2d.play("slide_down")

func _update_animation(dir: Vector2) -> void:
	if is_rolling or is_slide_recovering:
		return
	
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
