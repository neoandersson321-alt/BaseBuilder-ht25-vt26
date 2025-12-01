extends Node2D


@onready var spawn_positions = [$TopLeft, $TopRight, $BottomLeft, $BottomRight]

var center_pos: Vector2
var current_wave := 0
var time_between_waves := 5

signal wave_countdown_update(remaining_time: float)
signal wave_starting(wave_number: int)
signal all_waves_done()

@export var waves = [ 
		[{"type": preload("res://Scenes/Enemy/enemy.tscn"), "count": 5, "delay": 0.2}],
		[{"type": preload("res://Scenes/Enemy/enemy.tscn"), "count": 10, "delay": 0.2}],
		[{"type": preload("res://Scenes/Enemy/enemy.tscn"), "count": 20, "delay": 0.2}]
	 ]


func start(building_position: Vector2):
	center_pos = building_position
	global_position = building_position
	start_next_wave()


func start_next_wave():
	if current_wave >= waves.size():
		emit_signal("all_waves_done")
		return
	
	await wave_countdown(time_between_waves)
	
	emit_signal("wave_starting", current_wave + 1)
	spawn_wave(waves[current_wave])
	current_wave += 1

func wave_countdown(duration):
	var remaining = duration
	while remaining > 0:
		emit_signal("wave_countdown_update", remaining)
		await get_tree().create_timer(1.0).timeout
		remaining -= 1
	

func spawn_wave(wave_data):
	# wave_data är en LISTA med subwaves
	for subwave in wave_data:
		var enemy_type = subwave["type"]
		var count = subwave["count"]
		var delay = subwave["delay"]
		for i in count:
			spawn_enemy(enemy_type)
			await get_tree().create_timer(delay).timeout
		
		await wait_for_all_enemies()
	start_next_wave()


func spawn_enemy(enemy_type):
	var enemy = enemy_type.instantiate()
	enemy.position = spawn_positions.pick_random().position
	add_child(enemy)


func wait_for_all_enemies():
	while get_tree().get_nodes_in_group("enemies").size() > 0:
		await get_tree().create_timer(5).timeout
