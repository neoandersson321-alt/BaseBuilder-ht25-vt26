extends Node2D

var gridsize: int = 16
var Dic = {}
var awailable_tiles = ["GRASS", "WATER", "BUILDING"]
var current_tile = "GRASS"

var build_mode: bool = false
var build_valid: bool = false
var preview_node: Node

@onready var base_layer: TileMapLayer = $BaseLayer
@onready var outline_layer: TileMapLayer = $OutlineLayer
@onready var building_layer: TileMapLayer = $BuildingLayer

func _ready() -> void:
	
	for x in range(gridsize):
		for y in range(gridsize):
			var pos = Vector2i(x, y)
			Dic[pos] = {
				"Type":"Grass"
				}
			
			base_layer.set_cell(pos, 0, Vector2i(0,0), 0)



	#
	#if event.is_action_pressed("BuildMode"):
		#if build_mode:
			#build_mode = false
			#preview_node.queue_free()
		#else:
			#_set_building_preview("ex_canon")
			#build_mode = true
#




func _change_tile(tile):
	Dic[get_tile()] = {"Type": tile}


func get_tile() -> Vector2i:
	return Vector2i(building_layer.local_to_map(building_layer.get_local_mouse_position()))




func _change_preview_position():
	preview_node.position = get_tile()*128 + Vector2i(64,64)


func _place_building(building_type):
	var building = load("res://Scenes/Buildings/" + building_type + ".tscn").instantiate()
	
	$"../Buildings".add_child(building)
	building.position = Vector2(64 + get_tile().x * 128, 64 + get_tile().y * 128)


func _check_building_validity():
	if Dic.has(get_tile()):
		if Dic[get_tile()] == {"Type": "Grass"}:
			build_valid  = true
		else:
			build_valid = false
