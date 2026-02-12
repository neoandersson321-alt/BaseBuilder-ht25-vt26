extends CharacterBody2D

# --- Stats direkt på noden ---
@export var max_hp: float = 75
@export var speed: float = 100
@export var tower_damage: float = 10
@export var player_damage: float = 10
@export var regen_rate: float = 0.0
@export var ranged_attack_speed: float = 1.0
@export var normal_attack_speed: float = 1.0

# --- Modifierare ---
enum Modifier {
	FAST,
	TANK,
	RANGED,
	SPLIT_ON_DEATH,
	REGEN,
	AVOID_TOWERS,
}
@export var modifiers: Array[Modifier] = []  # t.ex. ["fast", "tank", "ranged", "split_on_death"]

########## variabler för tornet ##############
@onready var attack_area: Area2D = $AttackArea
var colliding_towers: Array = []
var colliding_players: Array = []
var center_pos: Vector2
var health: float
var time = 0.0
var attack_time = 1.0

############ signaler #########
signal enemy_died


func _ready():
	health = max_hp
	attack_time = ranged_attack_speed if Modifier.RANGED in modifiers else normal_attack_speed

	center_pos = get_parent().global_position
	add_to_group("enemies")

	attack_area.body_entered.connect(_body_entered)
	attack_area.body_exited.connect(_body_exited)

	
	if Modifier.REGEN in modifiers: # sätta igång regen om det finns
		start_regen()


func _process(delta):
	movement(delta)
	attack_timer(delta)


func movement(delta):
	var dir_to_center = global_position.direction_to(center_pos)
	look_at(center_pos)

	if Modifier.AVOID_TOWERS in modifiers:
		if global_position.distance_to(center_pos) > 100:
			if get_collision_mask_value(1) and get_collision_mask_value(6):
				set_collision_mask_value(1, false)
				set_collision_mask_value(6, false)
		else:
			set_collision_mask_value(1, true)
			set_collision_mask_value(6, true)

	velocity = dir_to_center * speed
	move_and_slide()


func attack_timer(delta):
	time += delta
	if time >= attack_time:
		time = 0
		attack()


func attack():
	if Modifier.RANGED in modifiers:
		shoot_projectile()
	else:
		for tower in colliding_towers:
			tower.take_damage(tower_damage)
		for player in colliding_players:
			player.take_damage(player_damage)


func take_damage(amount):
	if Modifier.TANK in modifiers:
		amount *= 0.5  # Tank tar halv skada
	health -= amount

	if health <= 0:
		_die()


func _die():
	if Modifier.SPLIT_ON_DEATH in modifiers:
		split_into_minions()
	emit_signal("enemy_died")
	queue_free()


# --- Modifier-funktioner ---
func start_regen():
		while is_inside_tree() and health > 0:
			health = min(health + regen_rate * get_process_delta_time(), max_hp)



func split_into_minions():
	var minion_scene = preload("res://Scenes/Enemy/enemy.tscn")
	for i in 3:
		var minion = minion_scene.instantiate()
		minion.global_position = global_position
		get_parent().add_child(minion)


func shoot_projectile():
	var projectile_scene = preload("res://Scenes/Enemy/projectile.tscn")
	var projectile = projectile_scene.instantiate()

	projectile.tower_damage = tower_damage
	projectile.player_damage = player_damage
	projectile.global_position = global_position
	projectile.direction = global_position.direction_to(center_pos)
	get_parent().add_child(projectile)

func _body_entered(body):
	if body.is_in_group("towers"):
		colliding_towers.append(body)
	elif body.is_in_group("player"):
		colliding_players.append(body)


func _body_exited(body):
	if body.is_in_group("towers"):
		colliding_towers.erase(body)
	elif body.is_in_group("player"):
		colliding_players.erase(body)
