extends Node2D
@onready var upgrade_button: Button = $UpgradeButton
@onready var game_scene: Node2D = get_parent().get_parent().get_parent()
@onready var fire_timer: Timer = $FireTimer
@export var projectile_scene: PackedScene
@export var building_name: String

var health: float
var range: float
var rof: float
var damage: int
var center_pos: Vector2 # endast relevant om det är centertornet som skapas
var buc: Dictionary # Base Upgrade Cost
var upgrade_cost: Dictionary

var target: Node2D = null
signal upgrade_button_pressed

func _ready() -> void:
	fire_timer.connect("timeout", Callable(self, "_on_fire_timer_timeout"))
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
	buc = data["upgrade_cost"]
	health = data["health"]
	upgrade_cost = buc

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
	
	for enemy in enemies:
		if not enemy.is_inside_tree():
			continue
		
		if global_position.distance_to(enemy.global_position) > range:
			continue
		
		var dist_to_center = center_pos.distance_to(enemy.global_position)
		
		if dist_to_center < closest_dist_center:
			closest_dist_center = dist_to_center
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
	range *= 1.1
	damage *= 1.1
	rof *= 0.9
	fire_timer.wait_time = rof

############ damage functions ##############

func take_damage(damage):
	health -= damage
	if health <= 0:
		dead()

func dead():
	if name == "DragBuilding":
		return
	game_scene.delete_tower(name)
