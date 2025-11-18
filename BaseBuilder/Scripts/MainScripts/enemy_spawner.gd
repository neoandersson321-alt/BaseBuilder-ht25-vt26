extends Node2D


var enemy_scene = preload("res://Scenes/Enemy/enemy.tscn")

@export var timer: Timer

@onready var top_left =$TopLeft
@onready var top_right =$TopRight
@onready var bottom_left =$BottomLeft
@onready var bottom_right =$BottomRight
var center_pos: Vector2

func start(building_position: Vector2):
	center_pos = building_position
	global_position = building_position
	timer.start()

func _ready() -> void:
	pass


rand
func _on_timer_timeout() -> void:
	var enemy = enemy_scene.instantiate()
	
	add_child(enemy)
