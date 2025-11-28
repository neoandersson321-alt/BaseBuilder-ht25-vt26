extends Node2D


var enemy_scene = preload("res://Scenes/Enemy/enemy.tscn")

@export var timer: Timer

@onready var top_left =$TopLeft
@onready var top_right =$TopRight
@onready var bottom_left =$BottomLeft
@onready var bottom_right =$BottomRight

@onready var enemies = $Enemies

@onready var spawn_positions = [top_left, top_right, bottom_left, bottom_right]
var center_pos: Vector2

var current_wave = 0
var enemies_in_wave = 0

func _ready() -> void:
	randomize()

func start(building_position: Vector2):
	center_pos = building_position
	global_position = building_position
	start_next_wave()



	#### Wave Functions ################
func start_next_wave():
	var retrieved_wave_data = retrieve_wave_data()
	await get_tree().create_timer(0.2).timeout
	spawn_enemies(retrieved_wave_data)

func retrieve_wave_data() -> Array:
	var wave_data = [["enemy", 0.7], ]
	current_wave += 1
	enemies_in_wave = wave_data.size()
	return wave_data

func spawn_enemies(wave_data):
	for index in wave_data:
		var new_enemy = load("res://Scenes/Enemy/" + str(index[0]) + ".tscn").instantiate()
		var spawn_num = randi_range(0, 3)
		new_enemy.position = spawn_positions[spawn_num].position
		enemies.add_child(new_enemy)
		await get_tree().create_timer(index[1])
