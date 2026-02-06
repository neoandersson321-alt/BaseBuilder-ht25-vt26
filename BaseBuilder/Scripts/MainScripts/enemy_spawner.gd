extends Node2D


@onready var spawn_positions = [$TopLeft, $TopRight, $BottomLeft, $BottomRight]
@onready var wave_timer = $WaveTimer
var center_pos: Vector2
var current_wave := 0
var time_between_waves := 5

var alive_enemies := 0

signal wave_countdown_update(remaining_time: float)
signal wave_starting(wave_number: int)
signal all_waves_done()
signal countdown_started(countdown_time: float)
signal wave_cleared

@export var waves = [ 
		[{"type": preload("res://Scenes/Enemy/enemy.tscn"), "count": 5, "delay": 5.0},
		{"type": preload("res://Scenes/Enemy/enemy.tscn"), "count": 5, "delay": 0.2}],
		[{"type": preload("res://Scenes/Enemy/enemy.tscn"), "count": 10, "delay": 0.2}],
		[{"type": preload("res://Scenes/Enemy/enemy.tscn"), "count": 20, "delay": 0.2}]
	 ]

func _ready() -> void:
	wave_timer.wait_time = time_between_waves

func start(building_position: Vector2):
	center_pos = building_position
	global_position = building_position
	start_next_wave()


func start_next_wave():
	if current_wave >= waves.size():
		emit_signal("all_waves_done")
		return
	wave_timer.start()
	wave_countdown()



func wave_countdown():
	var remaining = time_between_waves
	emit_signal("countdown_started", remaining)

func spawn_wave(wave_data):
	# wave_data är en LISTA med subwaves
	for subwave in wave_data:
		var enemy_type = subwave["type"]
		var count = subwave["count"]
		var delay = subwave["delay"]
		for i in count:
			spawn_enemy(enemy_type)
			await get_tree().create_timer(delay).timeout
		
	await wave_cleared
	start_next_wave()


func spawn_enemy(enemy_type):
	var enemy = enemy_type.instantiate()
	alive_enemies += 1
	enemy.enemy_died.connect(_on_enemy_dead)
	enemy.position = spawn_positions.pick_random().position
	add_child(enemy)


func _on_wave_timer_timeout() -> void:
	emit_signal("wave_starting", current_wave + 1)
	spawn_wave(waves[current_wave])
	current_wave += 1

func _on_enemy_dead():
	alive_enemies -= 1
	if alive_enemies <= 0:
		emit_signal("wave_cleared")
