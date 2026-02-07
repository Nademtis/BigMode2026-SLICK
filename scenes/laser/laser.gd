extends Line2D 
#laser

var is_powered : bool = true

@onready var area_2d: Area2D = $Area2D

var red_color: Color
var no_color: Color = Color(0.0, 0.0, 0.0, 0.0)

enum Direction {
	RIGHT_LEFT,
	DOWN_UP
}

@onready var collision_polygon_2d: CollisionPolygon2D = $Area2D/CollisionPolygon2D
@export var direction: Direction = Direction.RIGHT_LEFT

@onready var shadow_line_2d: Line2D = $shadowLine2d

func on_generator_power_changed(is_on: bool) -> void:
	if is_on:
		is_powered = true
		default_color = red_color
		shadow_line_2d.visible = true
		area_2d.monitoring = true
	else:
		is_powered = false
		default_color = no_color
		shadow_line_2d.visible = false
		area_2d.monitoring = false

func _ready() -> void:
	red_color = default_color
	
	set_coll()
	set_shadow()
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var player : Player = body
		if !player.is_rolling:
			print("!!!laser found player!!!")
		#TODO slow player?
		#TODO start alarm and countdown

func set_shadow() -> void:
	if direction == Direction.RIGHT_LEFT:
		shadow_line_2d.points = self.points
		shadow_line_2d.position = shadow_line_2d.position + Vector2(0, 5)


func set_coll() -> void:
	if points.is_empty():
		push_error("laser points not set")
	
	var new_coll_polygon : PackedVector2Array
	var point_1 : Vector2
	var point_2 : Vector2
	var point_3 : Vector2
	var point_4 : Vector2
	
	if direction == Direction.DOWN_UP:
		point_1 = Vector2(points[0].x - 1, points[0].y)
		point_2 = Vector2(points[0].x + 1, points[0].y)
		
		point_3 = Vector2(points[1].x - 1, points[1].y)
		point_4 = Vector2(points[1].x + 1, points[1].y)
		
		new_coll_polygon.append(point_1)
		new_coll_polygon.append(point_2)
		new_coll_polygon.append(point_3)
		new_coll_polygon.append(point_4)
		
		collision_polygon_2d.polygon = new_coll_polygon
	else:
		point_1 = Vector2(points[0].x, points[0].y - 1)
		point_2 = Vector2(points[0].x, points[0].y + 1)
		
		point_3 = Vector2(points[1].x, points[1].y - 1)
		point_4 = Vector2(points[1].x, points[1].y + 1)
		
		new_coll_polygon.append(point_1)
		new_coll_polygon.append(point_2)
		new_coll_polygon.append(point_3)
		new_coll_polygon.append(point_4)
		
		collision_polygon_2d.polygon = new_coll_polygon
		
