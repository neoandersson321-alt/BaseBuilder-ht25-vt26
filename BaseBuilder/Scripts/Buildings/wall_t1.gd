extends Node2D

signal wall_hit

@onready var upgrade_button: Button = $UpgradeButton
@onready var game_scene: Node2D = get_parent().get_parent().get_parent()
@export var building_name: String

var buc: Dictionary # Base Upgrade Cost
var upgrade_cost: Dictionary
var health: float

signal upgrade_button_pressed

func _ready() -> void:
	if name != "DragBuilding":
		if is_instance_valid(upgrade_button):
			upgrade_button.pressed.connect(_on_upgrade_button_pressed.bind(self))
	else:
		if is_instance_valid(upgrade_button):
			upgrade_button.queue_free()
	load_building_stats()


func load_building_stats():
	var data = GameData.tower_data[building_name]
	buc = data["upgrade_cost"]
	health = data["health"]
	upgrade_cost = buc


################# UPGRADE FUNCTIONS ############
func update_upgrade_cost():
	for resource in upgrade_cost:
		upgrade_cost[resource] *= 1.1
		upgrade_cost[resource] = ceili(upgrade_cost[resource])
	print(upgrade_cost)

func _on_upgrade_button_pressed(tower):
	if ! game_scene.enough_resources_upgrade(upgrade_cost):
		print("not enough resources")
		return
	print(str(tower) + " Has Been Upgraded")
	upgrade_stats()
	update_upgrade_cost()

func upgrade_stats():
	pass

############ damage functions #############

func take_damage(damage): # denna callas av hitboxen
	health -= damage
	if health <= 0:
		dead()

func dead():
	game_scene.delete_tower(name, true)
