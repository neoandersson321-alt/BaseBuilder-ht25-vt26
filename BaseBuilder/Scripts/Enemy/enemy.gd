extends CharacterBody2D
class_name EnemyBase


@onready var enemy_spawner = get_parent()

@export var type_data: EnemyStats
var center_pos: Vector2
var health := 75
var speed := 100


func _ready() -> void:
	center_pos = enemy_spawner.global_position
	add_to_group("enemies")



func _process(delta: float) -> void:
	movement()


func _take_damage(amount):
	health -= amount
	if health <= 0:
		_die()


func _die():
	queue_free()


func movement():
	var dir_to_center = self.global_position.direction_to(center_pos)
	look_at(center_pos)
	velocity = dir_to_center * speed
	move_and_slide()
