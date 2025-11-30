extends Node2D


@onready var upgrade_button: Button = $UpgradeButton
@onready var game_scene: Node2D = get_parent().get_parent().get_parent()
@onready var fire_timer: Timer= $FireTimer

@export var building_name:String

var range: float
var rof: float
var damage: int
var center_pos: Vector2
var target: Node2D = null

signal upgrade_button_pressed

func _ready() -> void:
	if name != "DragBuilding":
		upgrade_button.pressed.connect(_on_upgrade_button_pressed.bind(self))
	else:
		upgrade_button.queue_free()
	center_pos = game_scene.center_pos
	load_building_stats()
	fire_timer.wait_time = rof
	fire_timer.start()


func load_building_stats():
	var data = GameData.tower_data[building_name]
	range = data["range"]
	damage = data["damage"]
	rof = data["rate_of_fire"]

func _on_upgrade_button_pressed(tower):
	print(str(tower) + "Has Been Upgraded")

func _physics_process(delta: float) -> void:
	_find_target()
	_turn()


func _find_target():
# Hitta fiender i din grupp
	var enemies = get_tree().get_nodes_in_group("enemies")
	var closest = null
	var closest_dist = range

	for e in enemies:
		if not e.is_inside_tree():
			continue
		var d = center_pos.distance_to(e.global_position)
		if d < closest_dist:
			closest_dist = d
			closest = e

	target = closest

func _turn():
	if target == null:
		return
	var target_pos = target.global_position
	print(target_pos)
	look_at(target_pos)
