extends Node2D

@onready var top_left =$TopLeft
@onready var top_right =$TopRight
@onready var bottom_left =$BottomLeft
@onready var bottom_right =$BottomRight
@onready var spawn_positions = [top_left, top_right, bottom_left, bottom_right]
var center_pos: Vector2



func start(building_position: Vector2):
	center_pos = building_position
	global_position = building_position
	start_next_wave()

var waves = [ 
	[
		# Våg 1
		{"type": preload("res://Data/Enemy/enemy_zombie.tres"), "count": 5, "delay": 0.5}
		]
	 ]
var current_wave := 0
var spawning := false


func start_next_wave():
	print(current_wave)
	if current_wave >= waves.size():
		print("Alla waves klara!")
		return

	spawning = true
	spawn_wave(waves[current_wave])
	current_wave += 1

func spawn_wave(wave_data):
	# wave_data är en LISTA med subwaves
	for subwave in wave_data:
		var enemy_type = subwave["type"]
		var count = subwave["count"]
		var delay = subwave["delay"]
		for i in count:
			spawn_enemy(enemy_type)
			await get_tree().create_timer(delay).timeout

	spawning = false
	await wait_for_all_enemies()
	start_next_wave()


func spawn_enemy(enemy_type):
	var enemy = enemy_type.scene.instantiate()
	enemy.type_data = enemy_type  
	enemy.position = spawn_positions.pick_random().position
	add_child(enemy)


func wait_for_all_enemies():
	while get_tree().get_nodes_in_group("enemies").size() > 0:
		await get_tree().create_timer(0.2).timeout
