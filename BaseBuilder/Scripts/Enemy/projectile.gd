extends Area2D
class_name Projectile

@export var speed: float = 300

# dessa 3 sätts av fiendes som skuter skottet
var tower_damage: float
var player_damage: float
var direction: Vector2 

var time: float = 0.0
var max_alive_time: float = 2.0

signal hit_target

func _ready() -> void:
	look_at(direction)

func _process(delta):
	position += direction.normalized() * speed * delta
	time += delta
	if time >= max_alive_time:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("towers"):
		body.take_damage(tower_damage)
		queue_free()
	
	if body.is_in_group("player"):
		body.take_damage(player_damage)
		queue_free()
