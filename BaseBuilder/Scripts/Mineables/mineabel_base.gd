extends StaticBody2D
class_name Mineable

@export var mine_amount: int
@export var resource_type: String

@onready var detect_area = $DetectArea
@onready var overlapping_tools: Array[Area2D]

signal add_resource(type, amount)

func _ready() -> void:
	collision_layer = 8
	collision_mask = 16
	add_to_group("mineables")
	detect_area.area_entered.connect(_on_area_entered)
	detect_area.area_exited.connect(_on_area_exited)
	get_tree().call_group("game_scene", "register_single_mineable", self)

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("tools"):
		overlapping_tools.erase(area)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("tools"):
		overlapping_tools.append(area)
		if not area.attack_started.is_connected(on_tool_attack):
			area.attack_started.connect(on_tool_attack.bind(area))

func on_tool_attack(area):
	if overlapping_tools.has(area):
		gain_resource()


func gain_resource():
	var type = resource_type
	var amount = mine_amount
	add_resource.emit(type, amount)
