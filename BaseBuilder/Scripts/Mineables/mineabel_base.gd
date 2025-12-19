extends Area2D
class_name Mineable

@export var mine_amount: int
@export var resource_type: String

signal add_resource(type, amount)

func _ready() -> void:
	add_to_group("mineables")
	area_entered.connect(_on_area_entered)
	get_tree().call_group("game_scene", "register_single_mineable", self)


func _on_area_entered(area: Area2D) -> void:
	
	if area.is_in_group("tools"):
		gain_resource()



func gain_resource():
	var type = resource_type
	var amount = mine_amount
	add_resource.emit(type, amount)
