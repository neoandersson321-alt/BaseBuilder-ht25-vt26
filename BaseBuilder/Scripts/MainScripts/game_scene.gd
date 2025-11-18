extends Node2D

var map_node

var build_mode = false
var build_valid = false
var build_tile
var build_location
var build_type

@export var BaseLayer: TileMapLayer
@export var BuildingLayer: TileMapLayer
@export var OutlineLayer: TileMapLayer

@onready var enemy_spawner = $EnemySpawner



func _ready() -> void:
	map_node = $GridMap # ifall vi ska lägga till fler banor/genererade kartor
	
	for i in get_tree().get_nodes_in_group("build_buttons"): # skapar en array med noderna i "build_buttons"
		i.pressed.connect(initiate_build_mode.bind(i.name)) # callar ibm med namnet på i som parameter "tower_type"


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


func initiate_build_mode(tower_type):
	if build_mode:
		cancel_build_mode()
	build_type = tower_type + "_t1"
	build_mode = true
	$PreviewLayer.set_tower_preview(build_type, get_global_mouse_position())


func update_tower_preview():
	var mouse_position = get_local_mouse_position()
	var current_tile = BuildingLayer.local_to_map(mouse_position)
	var tile_position = BuildingLayer.map_to_local(current_tile)

	# get_cell_source_id() gör att vi kan få tag på en cell, om den är tom blir resultatet == -1
	if BuildingLayer.get_cell_source_id(current_tile) == -1: # Det vi kollar här är ifall det finns någon tile i vårat building lager
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
		var new_tower = load("res://Scenes/Buildings/" +build_type+ ".tscn").instantiate()
		new_tower.position = build_location
		$GridMap/Buildings.add_child(new_tower, true)
		$GridMap/BuildingLayer.set_cell(build_tile, 0, Vector2i(0,0))
		if $GridMap/Buildings/CenterBuilding != null:
			$EnemySpawner.start(new_tower.position)


func _outline():
	var mouse_position = get_global_mouse_position()
	var current_tile = BuildingLayer.local_to_map(mouse_position)
	
	OutlineLayer.clear()
	OutlineLayer.set_cell(current_tile, 0, Vector2i.ZERO)
