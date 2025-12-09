extends CanvasLayer

@onready var game_scene = get_parent()
@onready var wave_label = $HUD/WaveLabel

var inventory

func _ready() -> void:
	inventory = game_scene.inventory
	wave_label.visible = false



##################### UI BUTTONS ###############

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
	Engine.time_scale = 5

############# WAVE FUNCTIONS #########################

func _connect_to_spawner(spawner):
	print(spawner)
	spawner.connect("wave_countdown_update", _on_wave_countdown_update)
	spawner.connect("wave_starting", _on_wave_starting)
	spawner.connect("all_waves_done", _on_all_waves_done)

func _on_wave_countdown_update(time_left):
	wave_label.visible = true
	wave_label.text = "Next wave in: " + str(int(time_left))

func _on_wave_starting(wave_num):
	wave_label.text = "Wave " + str(wave_num) + " incoming!"
	await get_tree().create_timer(3.0).timeout
	wave_label.visible = false

func _on_all_waves_done():
	wave_label.visible = true
	wave_label.text = "All waves completed!"

func update_inventory():
	inventory = game_scene.inventory
