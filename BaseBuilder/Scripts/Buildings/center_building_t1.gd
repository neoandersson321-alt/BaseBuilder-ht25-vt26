extends Node2D
@onready var upgrade_button: Button = $UpgradeButton
@onready var game_scene: Node2D = get_parent().get_parent().get_parent()
@export var building_name: String
@onready var upgrade_menue: Control = $CenterBuildingUpgradeMenue

var cur_possible_builds: Dictionary

var health: float
var center_pos: Vector2 # endast relevant om det är centertornet som skapas
var buc: Dictionary # Base Upgrade Cost
var upgrade_cost: Dictionary

var target: Node2D = null
signal upgrade_button_pressed

func _ready() -> void:
	if name != "DragBuilding":
		upgrade_button.toggled.connect(_on_upgrade_button_toggled)
	else:
		upgrade_button.queue_free()
	center_pos = game_scene.center_pos
	load_building_stats()

func load_building_stats():
	var data = GameData.tower_data[building_name]
	upgrade_cost = data["upgrade_cost"].duplicate(true)
	health = data["health"]


################# UPGRADE FUNCTIONS ############
func update_upgrade_cost():
	for resource in upgrade_cost:
		upgrade_cost[resource] *= 1.5
		upgrade_cost[resource] = ceili(upgrade_cost[resource])
	print(upgrade_cost)

func updated_pb() -> Dictionary:
	var updated_pb = game_scene.update_possible_builds(cur_possible_builds.duplicate(), true)
	return updated_pb

func _on_upgrade_button_toggled(toggled_on: bool):
	if toggled_on:
		upgrade_menue.open_menue(upgrade_cost, updated_pb(), health * 1.1, cur_possible_builds, health)
	else:
		upgrade_menue.close_menue()


# upgrade_cost: Dictionary, pb_imp: Dictionary, health_imp: float, cur_pb: Dictionary,  cur_health: float

func upgrade_stats():
	if ! game_scene.enough_resources_upgrade(upgrade_cost):
		upgrade_menue.not_enough_resources()
		return
	health *= 1.1
	game_scene.update_possible_builds(cur_possible_builds)
	update_upgrade_cost()
	upgrade_menue.open_menue(upgrade_cost, updated_pb(), health * 1.1, cur_possible_builds, health)
############ damage functions ##############

func take_damage(damage): # denna callas av hitboxen
	health -= damage
	if health <= 0:
		dead()

func dead():
	game_scene.delete_tower(name)
	if building_name == "center_building_t1":
		game_scene.game_lost()
