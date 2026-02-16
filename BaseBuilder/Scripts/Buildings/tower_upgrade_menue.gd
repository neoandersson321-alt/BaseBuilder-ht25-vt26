extends Control

@export var upgrade_cost_label: Label

@export var range_improvement_label: Label
@export var damage_improvement_label: Label
@export var rof_improvement_label: Label

@export var range_label: Label
@export var damage_label: Label
@export var rof_label: Label

@export var range_container: HBoxContainer
@export var damage_container: HBoxContainer
@export var rof_container: HBoxContainer

@export var upgrade_button: Button

@export var no_resorces_warning: ColorRect

@onready var tower = get_parent()

func _ready() -> void:
	visible = false

func _process(delta: float) -> void:
	rotation = -tower.rotation
	global_position = tower.global_position + Vector2(-370, -500)

func open_menue(upgrade_cost: Dictionary, range_imp: float, damage_imp: float, rof_imp: float, cur_range: float, cur_damage: float, cur_rof: float):
	range_improvement_label.text = str(snapped(range_imp, 1))
	damage_improvement_label.text = str(snapped(damage_imp, 1))
	rof_improvement_label.text = str(snapped(rof_imp, 0.01))
	
	range_label.text = str(snapped(cur_range, 1))
	damage_label.text = str(snapped(cur_damage, 1))
	rof_label.text = str(snapped(cur_rof, 0.01))
	
	upgrade_cost_label.text = str(upgrade_cost)
	visible = true

func close_menue():
	visible = false


func _on_upgrade_button_pressed() -> void:
	tower.upgrade_stats()


func not_enough_resources():
	no_resorces_warning.visible = true
	await get_tree().create_timer(3, false).timeout
	no_resorces_warning.visible = false


func _on_sell_button_pressed() -> void:
	tower.sell()
