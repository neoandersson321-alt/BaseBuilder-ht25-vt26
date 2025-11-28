extends CharacterBody2D

@export var health:int
@export var damage:int
@export var speed:int
@export var hit_speed:int

@onready var enemy_spawner = get_parent()

var center_pos

func _ready() -> void:
	center_pos = enemy_spawner.global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	movement()



func movement():
	var dir_to_center = self.global_position.direction_to(center_pos)
	look_at(center_pos)
	velocity = dir_to_center * speed
	move_and_slide()
