extends CharacterBody2D

const MAX_SPEED = 500.0
const ACC = 7.0

var input: Vector2

func _get_move_input():
	input.x = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	input.y = Input.get_action_strength("Down") - Input.get_action_strength("Up")
	return input.normalized()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("LeftClick"):
		print("Attack!")
func _process(delta: float) -> void:
	var player_input = _get_move_input()
	velocity = lerp(velocity, player_input * MAX_SPEED, ACC*delta)
	
	look_at(get_global_mouse_position())
	move_and_slide()
