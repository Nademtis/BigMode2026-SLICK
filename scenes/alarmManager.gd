extends CanvasLayer

@onready var alarm_color_rect: ColorRect = $alarmColorRect
@onready var blinkalarm_timer: Timer = $BlinkalarmTimer

#alarm
var blinking_is_on : bool = false
var alarm_base_color := Color(1, 1, 1, 0.0)
var alarm_alert_color := Color(0.647, 0.188, 0.188, 0.192)
var alarm_target_color : Color
@export var alarm_lerp_speed := 6.0




func _ready() -> void:
	alarm_color_rect.color = alarm_base_color
	alarm_target_color = alarm_base_color

func _process(delta: float) -> void:
	alarm_color_rect.color = alarm_color_rect.color.lerp(
		alarm_target_color,
		delta * alarm_lerp_speed
	)
	
	
func call_the_cops() -> void:
	if blinkalarm_timer.is_stopped():
		blinkalarm_timer.start()

func reset_level() -> void:
	blinkalarm_timer.stop()
	blinking_is_on = false
	alarm_target_color = alarm_base_color
	

func _on_blinkalarm_timer_timeout() -> void:
	blinking_is_on = !blinking_is_on
	
	if blinking_is_on:
		alarm_target_color = alarm_alert_color
	else:
		alarm_target_color = alarm_base_color
