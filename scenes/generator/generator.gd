extends Interactable
class_name Generator

var is_turned_on : bool = true

#@export var electronic_object_list : Array[electronicObject] 

func _ready() -> void:
	connect("player_interacted", update_electronic_objects)
	
func update_electronic_objects() -> void:
	is_turned_on = !is_turned_on
	print("this generator is: ", is_turned_on)
