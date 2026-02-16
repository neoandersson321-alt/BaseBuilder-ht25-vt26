extends Node2D


@onready var spawn_positions = [$TopLeft, $TopRight, $BottomLeft, $BottomRight]
@onready var wave_timer = $WaveTimer
var center_pos: Vector2
var current_wave := 0
var time_between_waves := 5

var alive_enemies := 0
var spawning: bool = true

signal wave_countdown_update(remaining_time: float)
signal wave_starting(wave_number: int)
signal all_waves_done()
signal countdown_started(countdown_time: float)
signal wave_cleared

var brute = preload("res://Scenes/Enemy/brute.tscn")
var enemy = preload("res://Scenes/Enemy/enemy.tscn")
var speedster = preload("res://Scenes/Enemy/speedster.tscn")

@export var waves = [ 
	[ # Wave 1 lugn start
		{"type": enemy, "count": 5, "delay": 5.0},
	],
	[ # Wave 2 lite högre press
		{"type": enemy, "count": 10, "delay": 2}
	],
	[ # Wave 3 ny fiende
		{"type": brute, "count": 5, "delay": 1},
		{"type": enemy, "count": 10, "delay": 0.5},
	],

	# Wave 4 – blandad press
	[
		{"type": enemy, "count": 8, "delay": 0.5},
		{"type": speedster, "count": 5, "delay": 0.5},
	],

	# Wave 5 – tank + support
	[
		{"type": brute, "count": 3, "delay": 1.0},
		{"type": enemy, "count": 12, "delay": 0.15},
	],

	# Wave 6 – tempochock
	[
		{"type": speedster, "count": 10, "delay": 0.1},
	],

	# Wave 7 – tryck från flera håll
	[
		{"type": enemy, "count": 10, "delay": 0.2},
		{"type": speedster, "count": 10, "delay": 0.15},
		{"type": brute, "count": 4, "delay": 0.8},
	],

	# Wave 8 – miniboss-känsla
	[
		{"type": brute, "count": 8, "delay": 0.6},
		{"type": speedster, "count": 12, "delay": 0.1},
	],

	# Wave 9 – kaos
	[
		{"type": enemy, "count": 20, "delay": 0.1},
		{"type": speedster, "count": 15, "delay": 0.1},
		{"type": brute, "count": 6, "delay": 0.5},
	]
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
	spawning = true
	# wave_data är en LISTA med subwaves
	for subwave in wave_data:
		var enemy_type = subwave["type"]
		var count = subwave["count"]
		var delay = subwave["delay"]
		for i in count:
			spawn_enemy(enemy_type)
			await get_tree().create_timer(delay, false).timeout
		
	spawning = false
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
	print(alive_enemies)
	if alive_enemies <= 0 and ! spawning:
		emit_signal("wave_cleared")
