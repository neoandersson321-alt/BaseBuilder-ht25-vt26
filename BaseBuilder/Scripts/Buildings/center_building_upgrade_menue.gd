extends Control

@export var upgrade_cost_label: Label

@export var pb_improvement_label: Label
@export var health_improvement_label: Label

@export var pb_label: Label
@export var health_label: Label

@export var pb_container: HBoxContainer
@export var health_container: HBoxContainer

@export var upgrade_button: Button
@export var sell_button: Button

@export var no_resorces_warning: ColorRect

@onready var tower = get_parent()
func _ready() -> void:
	visible = false
	upgrade_button.pressed.connect(_on_upgrade_button_pressed)

func open_menue(upgrade_cost: Dictionary, pb_imp: Dictionary, health_imp: float, cur_pb: Dictionary,  cur_health: float):
	pb_improvement_label.text = str(pb_imp)
	health_improvement_label.text = str(snapped(health_imp, 1))
	
	pb_label.text = str(cur_pb)
	health_label.text = str(snapped(cur_health, 1))
	
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
