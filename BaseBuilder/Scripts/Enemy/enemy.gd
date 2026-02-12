extends CharacterBody2D
class_name EnemyBase


@onready var enemy_spawner = get_parent()

@export var type_data: EnemyStats
@onready var attack_area: Area2D = $AttackArea

var colliding_towers = []
var colliding_players = []

var center_pos: Vector2

@export var health := 75
@export var speed := 100
@export var tower_damage: float
@export var player_damage: float

var time = 0.0
var attack_time = 1.0

var delta_time 
signal enemy_died

func _ready() -> void:
	center_pos = enemy_spawner.global_position
	add_to_group("enemies")
	attack_area.body_entered.connect(_body_entered)
	attack_area.body_exited.connect(_body_exited)

func _process(delta: float) -> void:
	movement()
	delta_time = delta


func attack_timer():
	time += delta_time
	if time >= attack_time:
		time = 0
		attack()

func attack():
	for tower in colliding_towers:
		tower.take_damage(tower_damage)
	for player in colliding_players:
		player.take_damage(player_damage)

func take_damage(amount):
	health -= amount
	print(amount)
	if health <= 0:
		_die()


func _die():
	emit_signal("enemy_died")
	queue_free()


func movement():
	var dir_to_center = self.global_position.direction_to(center_pos)
	look_at(center_pos)
	velocity = dir_to_center * speed
	move_and_slide()

func _body_entered(body: Node2D):
	if body.is_in_group("towers"):
		colliding_towers.append(body)
		attack_timer()
	elif body.is_in_group("player"):
		colliding_players.append(body)
		attack_timer()

func _body_exited(body: Node2D):
	if body.is_in_group("towers"):
		colliding_towers.erase(body)
	elif body.is_in_group("player"):
		colliding_players.erase(body)
