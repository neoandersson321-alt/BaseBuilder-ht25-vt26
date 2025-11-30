extends CharacterBody2D
class_name EnemyBase


@onready var enemy_spawner = get_parent()

@export var type_data: EnemyStats
var center_pos: Vector2
var health: int
var speed: float


func _ready() -> void:
	center_pos = enemy_spawner.global_position
	add_to_group("enemies")
	health = type_data.health
	speed = type_data.speed


func _process(delta: float) -> void:
	movement()



func movement():
	var dir_to_center = self.global_position.direction_to(center_pos)
	look_at(center_pos)
	velocity = dir_to_center * speed
	move_and_slide()
