extends Node2D
@onready var upgrade_button: Button = $UpgradeButton
@onready var game_scene: Node2D = get_parent().get_parent().get_parent()
@onready var fire_timer: Timer = $FireTimer
@export var projectile_scene: PackedScene
@export var building_name: String
var range: float
var rof: float
var damage: int
var center_pos: Vector2
var target: Node2D = null
var aim_lock_time: float = 0.0  # Tid kvar tills vi kan byta mål
var aim_lock_duration: float = 0.3  # Hur länge vi håller siktet efter skott (i sekunder)
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
	print(str(tower) + " Has Been Upgraded")

func _physics_process(delta: float) -> void:
	# Minska aim lock timer
	if aim_lock_time > 0:
		aim_lock_time -= delta
	
	# Bara leta efter nytt mål om vi inte är "låsta" och behöver ett nytt mål
	if aim_lock_time <= 0:
		# Kolla om vi behöver ett nytt mål
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
	
	_shoot()
	# Efter att ha skjutit, lås siktet för en kort stund
	aim_lock_time = aim_lock_duration

func _shoot():
	var bullet = projectile_scene.instantiate()
	$Bullets.add_child(bullet)
	bullet.global_position = global_position
	bullet.target = target

func _turn(delta):
	if target == null:
		return
	# Använd en lägre interpolation för mjukare rotation
	rotation = lerp_angle(rotation, (target.global_position - global_position).angle(), 0.08)
