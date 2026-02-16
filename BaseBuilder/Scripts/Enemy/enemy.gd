extends CharacterBody2D
class_name EnemyBase


@onready var enemy_spawner = get_parent()
@onready var attack_timer = $AttackTimer
@export var type_data: EnemyStats
@onready var attack_area: Area2D = $AttackArea

var colliding_towers = []
var colliding_players = []

var center_pos: Vector2

@export var health := 75
@export var speed := 100
@export var tower_damage: float
@export var player_damage: float
@export var attack_delay = 1.0

var delta_time 
signal enemy_died

func _ready() -> void:
	attack_timer.wait_time = attack_delay
	center_pos = enemy_spawner.global_position
	add_to_group("enemies")
	attack_area.body_entered.connect(_body_entered)
	attack_area.body_exited.connect(_body_exited)

func _process(delta: float) -> void:
	movement()



func attack():
	for tower in colliding_towers:
		tower.take_damage(tower_damage)
		attack_timer.start()
	for player in colliding_players:
		player.take_damage(player_damage)
		attack_timer.start()

func take_damage(amount):
	health -= amount
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
		attack_timer.start()
	elif body.is_in_group("player"):
		colliding_players.append(body)
		attack_timer.start()


func _body_exited(body: Node2D):
	if body.is_in_group("towers"):
		colliding_towers.erase(body)
		attack_timer.stop()
	elif body.is_in_group("player"):
		colliding_players.erase(body)


func _on_attack_timer_timeout() -> void:
	attack()
