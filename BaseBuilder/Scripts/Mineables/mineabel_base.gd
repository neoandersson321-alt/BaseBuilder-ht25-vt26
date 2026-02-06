extends StaticBody2D
class_name Mineable

@export var mine_amount: int
@export var resource_type: String

@onready var detect_area = $DetectArea
@onready var overlapping_tools: Array[Area2D]

var already_attacked: bool = false
var attack_window: bool = false

signal add_resource(type, amount)

func _ready() -> void:
	collision_layer = 8
	collision_mask = 16
	add_to_group("mineables")
	detect_area.area_entered.connect(_on_area_entered)
	detect_area.area_exited.connect(_on_area_exited)
	get_tree().call_group("game_scene", "register_single_mineable", self)

func _physics_process(delta: float) -> void:
	for tool in overlapping_tools:
		if attack_window and ! already_attacked:
			mineable_hit()

func mineable_hit():
	gain_resource()
	already_attacked = true
	reset_attack_timer(0.5)

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("tools"):
		overlapping_tools.erase(area)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("tools"):
		overlapping_tools.append(area)
		if not area.attack_started.is_connected(on_tool_attack):
			if area.attack_window:
				mineable_hit()
			area.attack_started.connect(on_tool_attack.bind(area))

func on_tool_attack(area):
	attack_window = true
	await get_tree().create_timer(area.attack_time).timeout
	attack_window = false

func reset_attack_timer(attack_time: float):
	await  get_tree().create_timer(attack_time).timeout
	already_attacked = false


func gain_resource():
	var type = resource_type
	var amount = mine_amount
	add_resource.emit(type, amount)
	
