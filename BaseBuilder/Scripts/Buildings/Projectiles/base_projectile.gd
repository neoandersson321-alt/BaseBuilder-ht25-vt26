extends Area2D

var tower_name: String
var speed: int
var damage: int
var target: Node2D
var dir: Vector2

var turn_speed: float = 0.5
var target_pos: Vector2

func _ready() -> void:
	var data = GameData.tower_data[tower_name]
	speed = data["bullet_speed"]
	damage = data["damage"]

	var notifier = VisibleOnScreenNotifier2D.new()
	add_child(notifier)
	
	body_entered.connect(_on_body_entered)
	notifier.screen_exited.connect(_on_screen_exited)
	
	dir = (target_pos - global_position).normalized()
func _physics_process(delta: float) -> void:
	global_position += dir * speed * delta
	look_at(target_pos)


func _on_body_entered(body):
	if body.is_in_group("enemies"):
		body._take_damage(damage)
		queue_free()


func _on_screen_exited():
	queue_free()
