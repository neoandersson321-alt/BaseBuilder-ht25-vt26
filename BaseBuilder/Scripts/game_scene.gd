extends Node2D

var map_node

var build_mode = false
var build_valid = false
var build_location
var build_type

func _ready() -> void:
	map_node = $GridMap # ifall vi ska lägga till fler banor/genererade kartor
	
	for i in get_tree().get_nodes_in_group("build_buttons"): # skapar en array med noderna i "build_buttons"
		i.pressed.connect(initiate_build_mode.bind(i.name)) # callar ibm med namnet på i som parameter "tower_type"

func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	pass

func initiate_build_mode(tower_type):
	build_type = tower_type + "T1"
	build_mode = true
	print(build_type)
	$UI.set_tower_preview(build_type, get_global_mouse_position())

func update_tower_preview():
	pass

func cancel_build_mode():
	pass

func verify_and_build():
	pass
