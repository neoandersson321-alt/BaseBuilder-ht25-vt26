extends Node2D

var gridsize: int = 16
var Dic = {}
var awailable_tiles = ["GRASS", "WATER", "BUILDING"]
var current_tile = "GRASS"

var build_mode: bool = false
var build_valid: bool = false
var preview_node: Node

@onready var BaseLayer: TileMapLayer = $BaseLayer
@onready var OutlineLayer: TileMapLayer = $OutlineLayer

func _ready() -> void:
	for x in range(gridsize):
		for y in range(gridsize):
			var pos = Vector2i(x, y)
			Dic[pos] = {
				"Type":"Grass"
				
				}
			
			BaseLayer.set_cell(pos, 0, Vector2i(0, 0))


func _process(_delta: float) -> void:
	_outline()
	if build_mode:
		_change_preview_position()
		_check_building_validity()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Left_Click") and build_mode and build_valid:
		_change_tile("BUILDING")
		_place_building("ex_canon")
	
	
	if event.is_action_pressed("BuildMode"):
		if build_mode:
			build_mode = false
			preview_node.queue_free()
		else:
			_set_building_preview("ex_canon")
			build_mode = true



func _outline():
	var tile = get_tile()
	
	OutlineLayer.clear()
	if Dic.has(tile):
		OutlineLayer.set_cell(tile, 0, Vector2i.ZERO)


func _chose_tile() -> int:
	if current_tile == "GRASS":
		return 0
	elif current_tile == "WATER":
		return 1
	return 0


func _change_tile(tile):
	Dic[get_tile()] = {"Type": tile}
	


func get_tile() -> Vector2i:
	return Vector2i(BaseLayer.local_to_map(BaseLayer.get_local_mouse_position()))


func _set_building_preview(building_type):
	var drag_building = load("res://Scenes/Buildings/" + building_type + ".tscn").instantiate()
	drag_building.set_name("Drag_building")
	drag_building.modulate = Color("ad54ff3c")
	drag_building.z_index = 100
	
	var control = Control.new()
	control.add_child(drag_building, true)
	control.position = Vector2(64 + get_tile().x * 128, 64 + get_tile().y * 128)
	control.set_name("Building_preview")
	add_child(control, true)
	preview_node = control


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
