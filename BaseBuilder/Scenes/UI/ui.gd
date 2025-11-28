extends CanvasLayer
@onready var game_scene = get_parent()


func disable_button(tower):
	var button = get_node("HUD/BuildBar/" + str(tower))
	button.disabled = true
	button.modulate = Color("828282af")


func _on_pause_play_pressed() -> void:
	if get_tree().is_paused():
		get_tree().paused = false
	else:
		get_tree().paused = true



func _on_x_speed_button_up() -> void:
	Engine.time_scale = 1


func _on_x_speed_button_down() -> void:
	print("speeeeeed")
	Engine.time_scale = 2
