extends Node2D

var map_node

var build_mode = false
var build_valid = false
var build_tile
var build_location
var build_type

var possible_builds = {"center_building_t1": 1, "gun_t1": 4, "missile_t1": 2}
var buildings = {"center_building_t1": 0, "gun_t1": 0, "missile_t1": 0}
@export var BaseLayer: TileMapLayer
@export var BuildingLayer: TileMapLayer
@export var OutlineLayer: TileMapLayer
@onready var enemy_spawner_scene = preload("res://Scenes/MainScenes/enemy_spawner.tscn")

@onready var ui = $UI
func _ready() -> void:
	map_node = $GridMap # ifall vi ska lägga till fler banor/genererade kartor
	
	for i in get_tree().get_nodes_in_group("build_buttons"): # skapar en array med noderna i "build_buttons"
		i.pressed.connect(initiate_build_mode.bind(i.name.replace("_t1",""))) # callar ibm med namnet på i som parameter "tower_type"


func _process(delta: float) -> void:
	if build_mode:
		update_tower_preview()
	_outline()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("RightClick") and build_mode:
		cancel_build_mode()
		print("yes")
	
	if event.is_action_released("LeftClick") and build_mode:
		verify_and_build()
		cancel_build_mode()

##### Build Functions #############
func initiate_build_mode(tower_type):
	if build_mode:
		cancel_build_mode()
	build_mode = true
	build_type = tower_type + "_t1"
	$PreviewLayer.set_tower_preview(build_type, get_global_mouse_position())


func update_tower_preview():
	var mouse_position = get_local_mouse_position()
	var current_tile = BuildingLayer.local_to_map(mouse_position)
	var tile_position = BuildingLayer.map_to_local(current_tile)

	# get_cell_source_id() gör att vi kan få tag på en cell, om den är tom blir resultatet == -1
	if BuildingLayer.get_cell_source_id(current_tile) == -1 and buildings[build_type] < possible_builds[build_type]: # Det vi kollar här är ifall det finns någon tile i vårat building lager
		$PreviewLayer.update_tower_preview(tile_position, "91ff63ca")
		build_valid = true
		build_location = tile_position
		build_tile = current_tile
	else: # Något finns på den tilen
		$PreviewLayer.update_tower_preview(tile_position, "ff2016a7")
		build_valid = false

func cancel_build_mode():
	build_mode = false
	build_valid = false
	$PreviewLayer/BuildingPreview.free()
	# spännande fel är tidigare, queue free fungerade ej utan free() behövdes, handlade om att vi refererar till
	# namnet på noden i UI och då blir det skumt om man entrar build mode från build mode, nya noden hinner skapas innan
	# den gamla togs bort

func verify_and_build():
	if build_valid:
		# kolla ifall spelaren har nog med resurser
		buildings[build_type] += 1
		if buildings[build_type] == possible_builds[build_type]:
			ui.disable_button(build_type)
		var new_tower = load("res://Scenes/Buildings/" +build_type+ ".tscn").instantiate()
		new_tower.position = build_location
		$GridMap/Buildings.add_child(new_tower, true)
		$GridMap/BuildingLayer.set_cell(build_tile, 0, Vector2i(0,0))
		if build_type ==  "center_building_t1":
			var enemy_spawner = enemy_spawner_scene.instantiate()
			add_child(enemy_spawner)
			enemy_spawner.start(new_tower.position)

#####################################


############
func _outline():
	var mouse_position = get_global_mouse_position()
	var current_tile = BuildingLayer.local_to_map(mouse_position)
	
	OutlineLayer.clear()
	OutlineLayer.set_cell(current_tile, 0, Vector2i.ZERO)
