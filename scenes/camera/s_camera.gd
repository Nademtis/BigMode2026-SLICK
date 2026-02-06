extends Node2D
#Camera

@onready var rotater: Node2D = $rotater

@onready var polygon_2d: Polygon2D = $rotater/Area2D/Polygon2D
@onready var collision_polygon_2d: CollisionPolygon2D = $rotater/Area2D/CollisionPolygon2D


func _ready() -> void:
	var polygon : PackedVector2Array = collision_polygon_2d.polygon
	polygon_2d.polygon = polygon
	
	


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("camera found player")
