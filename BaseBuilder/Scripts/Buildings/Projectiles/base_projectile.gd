extends Area2D

@onready var building = get_parent().get_parent()
var speed: int
var damage: int
var target: Node2D

func _ready() -> void:
	var data = GameData.tower_data[building.building_name]
	speed = data["bullet_speed"]
	damage = data["damage"]


func _physics_process(delta: float) -> void:
	if target == null:
		queue_free()
		return
	
	var dir = (target.global_position - global_position).normalized()
	global_position += dir * speed * delta
	if global_position.distance_to(target.global_position) < 10:
		if target.has_method("_take_damage"):
			target._take_damage(damage)
		queue_free()
