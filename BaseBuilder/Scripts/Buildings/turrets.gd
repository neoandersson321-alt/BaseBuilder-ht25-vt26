extends Node2D


@onready var upgrade_button: Button = $UpgradeButton
@onready var game_scene: Node2D = get_parent().get_parent().get_parent()
@onready var fire_timer: Timer= $FireTimer

@export var projectile_scene: PackedScene
@export var building_name:String


var range: float
var rof: float
var damage: int
var center_pos: Vector2
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

func _on_upgrade_button_pressed(tower):
	print(str(tower) + "Has Been Upgraded")

func _physics_process(delta: float) -> void:
	_find_target()
	_turn(delta)


func _find_target():
# Hitta fiender i din grupp
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
	
	_shoot()

func _shoot():
	var bullet = projectile_scene.instantiate()
	$Bullets.add_child(bullet)
	bullet.global_position = global_position
	bullet.target = target

func _turn(delta):
	if target == null:
		return
	rotation = lerp_angle(rotation,(target.global_position - global_position).angle(), 20 * delta)
