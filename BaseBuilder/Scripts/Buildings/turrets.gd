extends Node2D
@onready var upgrade_button: Button = $UpgradeButton
@onready var game_scene: Node2D = get_parent().get_parent().get_parent()
@onready var fire_timer: Timer = $FireTimer
@onready var upgrade_menue: Control = $TowerUpgradeMenue
@onready var range_overlay: Sprite2D = $RangeOverlay
@export var projectile_scene: PackedScene
@export var building_name: String

var health: float
var range: float
var rof: float
var damage: int
var center_pos: Vector2
var upgrade_cost: Dictionary

var center_building_exists: bool = false
var target: Node2D = null
signal upgrade_button_pressed

func _ready() -> void:
	fire_timer.connect("timeout", Callable(self, "_on_fire_timer_timeout"))
	if name != "DragBuilding":
		upgrade_button.toggled.connect(_on_upgrade_button_toggled)
	else:
		upgrade_button.queue_free()
	game_scene.center_building_built.connect(_on_center_building)
	load_building_stats()
	fire_timer.wait_time = rof
	fire_timer.start()

func _on_center_building():
	center_building_exists = true
	center_pos = game_scene.center_pos

func load_building_stats():
	var data = GameData.tower_data[building_name]
	range = data["range"]
	damage = data["damage"]
	rof = data["rate_of_fire"]
	upgrade_cost = data["upgrade_cost"].duplicate(true) # dduplicate behövedes här för att annars så skapades bara en referens till data["upgrade_cost"] -> alla torn fick samma upgrade_cost när jag upgraderade dem ):
	health = data["health"]

func _physics_process(delta: float) -> void:
	if target == null or not is_instance_valid(target) or not target.is_inside_tree():
		_find_target()
	# Eller om vårt nuvarande mål har gått utanför räckvidden
	elif target != null and global_position.distance_to(target.global_position) > range:
		_find_target()
	
	_turn(delta)

func _find_target():
	var enemies = get_tree().get_nodes_in_group("enemies")
	var closest_target = null
	var closest_dist_center = range
	var closest_dist_tower = range
	
	for enemy in enemies:
		if not enemy.is_inside_tree():
			continue
		
		if global_position.distance_to(enemy.global_position) > range:
			continue
		
		if center_building_exists:
			var dist_to_center = center_pos.distance_to(enemy.global_position)
			
			if dist_to_center < closest_dist_center:
				closest_dist_center = dist_to_center
				closest_target = enemy
		else:
			var dist_to_tower = global_position.distance_to(enemy.global_position)
			if dist_to_tower < closest_dist_center:
				closest_dist_center = dist_to_tower
				closest_target = enemy
	
	target = closest_target

func _on_fire_timer_timeout():
	if target == null:
		return
	if global_position.distance_to(target.global_position) > range:
		return
	
	await get_angle_to(target.global_position) < PI/8
	_shoot()

func _shoot():
	if name == "DragBuilding":
		return
	var bullet = projectile_scene.instantiate()
	bullet.damage = damage
	bullet.tower_name = building_name
	bullet.global_position = global_position
	bullet.target_pos = target.global_position
	bullet.target = target
	game_scene.get_node("Bullets").add_child(bullet)

func _turn(delta):
	if target == null:
		return
	# Använd en lägre interpolation för mjukare rotation
	rotation = lerp_angle(rotation, (target.global_position - global_position).angle(), 0.18)

################# UPGRADE FUNCTIONS ############
func update_upgrade_cost():
	for resource in upgrade_cost:
		upgrade_cost[resource] *= 1.5
		upgrade_cost[resource] = ceili(upgrade_cost[resource])


func _on_upgrade_button_toggled(toggled_on: bool):
	if toggled_on:
		upgrade_menue.open_menue(upgrade_cost, 	range * 1.1, damage * 1.1, rof * 0.9, range, damage, rof)
		
		range_overlay.scale = Vector2(range/600.0, range/600.0)
		range_overlay.visible = true
	else:
		upgrade_menue.close_menue()
		range_overlay.visible = false

func upgrade_stats():
	if ! game_scene.enough_resources_upgrade(upgrade_cost):
		upgrade_menue.not_enough_resources()
		return
	range *= 1.1
	range_overlay.scale = Vector2(range/600.0, range/600.0)
	damage *= 1.1
	rof *= 0.9
	fire_timer.wait_time = rof
	update_upgrade_cost()
	
	upgrade_menue.open_menue(upgrade_cost, 	range * 1.1, damage * 1.1, rof * 0.9, range, damage, rof)

func sell():
	var build_amount = GameData.tower_data[building_name]["tower_cost"].duplicate(true)
	var sell_amount: Dictionary
	for resource in build_amount:
		game_scene._gain_resource(resource, ceili(build_amount[resource]/2))
	dead()

############ damage functions ##############

func take_damage(damage):
	health -= damage
	if health <= 0:
		dead()

func dead():
	if name == "DragBuilding":
		return
	game_scene.delete_tower(name)
