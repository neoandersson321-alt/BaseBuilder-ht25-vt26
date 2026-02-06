extends CanvasLayer

@onready var game_scene = get_parent()
@onready var pause_menue = $HUD/PauseMenue
@onready var countdown_timer = $HUD/WaveLabel/Timer
@export var wave_label: Label
@export var stone_label: Label
@export var wood_label: Label

@onready var inventory_to_label = {
	"stone": stone_label, 
	"wood": wood_label,
}

var inventory
var wave_time # time between waves
var tbw # original time between waves
func _ready() -> void:
	inventory = game_scene.inventory
	wave_label.visible = false

##################### UI BUTTONS ###############

func disable_button(tower):
	var button = get_node("HUD/BuildBar/" + str(tower))
	button.disabled = true
	button.modulate = Color("828282af")

func _on_pause_button_pressed() -> void:
	pause()


func _on_x_speed_button_up() -> void:
	Engine.time_scale = 1


func _on_x_speed_button_down() -> void:
	Engine.time_scale = 5

############# WAVE FUNCTIONS #########################

func _connect_to_spawner(spawner):
	spawner.connect("wave_countdown_update", _on_wave_countdown_update)
	spawner.connect("wave_starting", _on_wave_starting)
	spawner.connect("all_waves_done", _on_all_waves_done)
	spawner.connect("countdown_started", _on_countdown_started)


func _on_countdown_started(time_between_waves: float):
	_on_wave_countdown_update(time_between_waves)
	tbw = time_between_waves
	wave_time = time_between_waves
	countdown_timer.start()
	

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
	
	for item in inventory:
		inventory_to_label[item].text = str(item) + ": " + str(inventory[item])

######## Pause Menue ###########

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		pause()

func pause():
	get_tree().paused = true
	pause_menue.visible = true


func _on_timer_timeout() -> void:
	wave_time -= 1
	if wave_time > 0:
		countdown_timer.start()
		_on_wave_countdown_update(wave_time)
	else:
		wave_time = tbw
